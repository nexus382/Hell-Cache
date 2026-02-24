#!/usr/bin/env python3
"""
GLM Model Benchmark Suite
==========================
Compare different models across various tasks and see which performs best.

Usage:
  python benchmark_models.py              # Run full benchmark
  python benchmark_models.py --quick      # Quick test (fewer questions)
  python benchmark_models.py --coding     # Only coding tests
  python benchmark_models.py --models glm-5,glm-4.7  # Test specific models
"""

import requests
import json
import time
import sys
import os
from datetime import datetime

# ============================================================================
# CONFIGURATION
# ============================================================================
API_KEY = os.getenv("ZHIPU_API_KEY", "8e3a3bdd1d2c45cb8ccecadfa73c01e9.xSlaPFASF4iSFQOV")
BASE_URL = "https://api.z.ai/api/anthropic/v1/messages"

# Models to test
AVAILABLE_MODELS = {
    "GLM-5": {"name": "GLM-5", "thinking_budget": 131999},
    "GLM-4.7": {"name": "GLM-4.7", "thinking_budget": 32000},
    "GLM-4.5-air": {"name": "GLM-4.5-air", "thinking_budget": 16000},
}

# ============================================================================
# TEST QUESTIONS - Different categories to test different abilities
# ============================================================================

TEST_QUESTIONS = {
    "math": [
        {
            "name": "Percentage Calculation",
            "difficulty": "easy",
            "question": "What is 15% of 847? Show your work.",
            "expected_answer": "127.05",
            "timeout": 30,
        },
        {
            "name": "Bayes Theorem",
            "difficulty": "hard",
            "question": """Factory A produces 40% of items (2% defect rate).
Factory B produces 35% of items (3% defect rate).
Factory C produces 25% of items (5% defect rate).
If an item is defective, what's the probability it came from Factory C? Use Bayes theorem.""",
            "expected_answer": "40.32",
            "timeout": 60,
        },
        {
            "name": "Mathematical Proof",
            "difficulty": "hard",
            "question": "Prove that the square root of 2 is irrational.",
            "expected_answer": "irrational",
            "timeout": 60,
        },
    ],

    "coding": [
        {
            "name": "Simple Function",
            "difficulty": "easy",
            "question": "Write a Python function that checks if a number is prime. Include docstring and example usage.",
            "expected_keywords": ["def", "prime", "return", "for"],
            "timeout": 45,
        },
        {
            "name": "Algorithm Implementation",
            "difficulty": "medium",
            "question": "Implement a binary search tree in Python with insert, search, and inorder traversal methods.",
            "expected_keywords": ["class", "Node", "insert", "search", "inorder", "left", "right"],
            "timeout": 90,
        },
        {
            "name": "Bug Fix",
            "difficulty": "medium",
            "question": """Fix this buggy Python code:

def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n+1)

print(fibonacci(10))

Explain what's wrong and provide the corrected version.""",
            "expected_keywords": ["n-2", "n-1", "fibonacci(n-2)", "bug", "error", "fix"],
            "timeout": 45,
        },
    ],

    "reasoning": [
        {
            "name": "Logic Puzzle",
            "difficulty": "medium",
            "question": """Three friends (Alice, Bob, Carol) each have a different pet (cat, dog, fish).
- Alice doesn't have a cat
- Bob doesn't have a dog
- Carol doesn't have a fish
- The person with the dog is older than Alice

Who has which pet? Show your reasoning step by step.""",
            "expected_keywords": ["Alice", "Bob", "Carol", "dog", "cat", "fish"],
            "timeout": 60,
        },
        {
            "name": "Critical Thinking",
            "difficulty": "hard",
            "question": """A company's revenue increased 20% while profits decreased 10%.
Give 3 possible explanations for this apparent contradiction.
Rank them by likelihood and explain your reasoning.""",
            "expected_keywords": ["cost", "margin", "expense", "investment", "competition"],
            "timeout": 60,
        },
    ],

    "writing": [
        {
            "name": "Technical Explanation",
            "difficulty": "easy",
            "question": "Explain REST APIs to a beginner in 3 paragraphs. Use simple analogies.",
            "expected_keywords": ["REST", "API", "request", "response", "HTTP"],
            "timeout": 45,
        },
        {
            "name": "Creative Writing",
            "difficulty": "medium",
            "question": "Write a 100-word story about a robot discovering music for the first time.",
            "expected_keywords": ["robot", "music", "sound", "melody"],
            "timeout": 45,
        },
    ],
}

# ============================================================================
# BENCHMARK FUNCTIONS
# ============================================================================

def call_model(model_name: str, question: str, thinking_budget: int, timeout: int = 60):
    """Call a model and return results."""
    start_time = time.time()

    try:
        response = requests.post(
            BASE_URL,
            headers={
                "Content-Type": "application/json",
                "x-api-key": API_KEY,
                "anthropic-version": "2023-06-01"
            },
            json={
                "model": model_name,
                "max_tokens": 4096,
                "messages": [{"role": "user", "content": question}],
                "thinking": {"type": "enabled", "budget_tokens": thinking_budget}
            },
            timeout=timeout + 10  # Extra buffer
        )

        elapsed = time.time() - start_time

        if response.status_code != 200:
            return {
                "success": False,
                "error": f"HTTP {response.status_code}: {response.text[:200]}",
                "elapsed": elapsed,
            }

        data = response.json()

        # Extract thinking and answer
        thinking = ""
        answer = ""
        for block in data.get("content", []):
            if block.get("type") == "thinking":
                thinking = block.get("thinking", "")
            elif block.get("type") == "text":
                answer = block.get("text", "")

        usage = data.get("usage", {})

        return {
            "success": True,
            "thinking": thinking,
            "answer": answer,
            "thinking_length": len(thinking),
            "answer_length": len(answer),
            "input_tokens": usage.get("input_tokens", 0),
            "output_tokens": usage.get("output_tokens", 0),
            "elapsed": elapsed,
            "stop_reason": data.get("stop_reason", "unknown"),
        }

    except requests.Timeout:
        return {"success": False, "error": "Timeout", "elapsed": timeout}
    except Exception as e:
        return {"success": False, "error": str(e), "elapsed": time.time() - start_time}


def evaluate_response(result: dict, test: dict) -> dict:
    """Evaluate the quality of a response."""
    if not result["success"]:
        return {"score": 0, "reason": result["error"]}

    answer = result["answer"].lower()
    score = 0
    reasons = []

    # Check for expected answer
    if "expected_answer" in test:
        expected = test["expected_answer"]
        if expected.lower() in answer:
            score += 50
            reasons.append(f"[OK] Contains expected answer: {expected}")
        else:
            reasons.append(f"[MISS] Missing expected answer: {expected}")

    # Check for expected keywords
    if "expected_keywords" in test:
        expected_kws = test["expected_keywords"]
        found = [kw for kw in expected_kws if kw.lower() in answer]
        keyword_score = (len(found) / len(expected_kws)) * 50
        score += keyword_score
        if found:
            found_str = ', '.join(found[:3])
            reasons.append(f"Keywords found ({len(found)}/{len(expected_kws)}): {found_str}...")
        else:
            reasons.append("No expected keywords found")

    # Bonus for thinking (shows reasoning)
    if result["thinking_length"] > 100:
        score += 5
        reasons.append(f"+5 thinking bonus ({result['thinking_length']} chars)")

    # Bonus for answer length (completeness)
    if result["answer_length"] > 200:
        score += 5
        reasons.append(f"+5 completeness bonus ({result['answer_length']} chars)")

    return {
        "score": min(score, 100),
        "reasons": reasons,
    }


def run_benchmark(models_to_test: list = None, categories: list = None, quick: bool = False):
    """Run the full benchmark suite."""

    if models_to_test is None:
        models_to_test = list(AVAILABLE_MODELS.keys())

    if categories is None:
        categories = list(TEST_QUESTIONS.keys())

    results = []

    print("\n" + "=" * 70)
    print("GLM MODEL BENCHMARK SUITE")
    print("=" * 70)
    print(f"Models: {', '.join(models_to_test)}")
    print(f"Categories: {', '.join(categories)}")
    print(f"Mode: {'Quick' if quick else 'Full'}")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70 + "\n")

    total_tests = 0
    for model_key in models_to_test:
        if model_key not in AVAILABLE_MODELS:
            print(f"WARNING: Unknown model '{model_key}', skipping...")
            continue

        model = AVAILABLE_MODELS[model_key]
        model_results = {
            "model": model_key,
            "tests": [],
            "total_score": 0,
            "total_time": 0,
            "total_tokens": 0,
            "success_count": 0,
        }

        print(f"\n{'='*70}")
        print(f"TESTING: {model_key}")
        print(f"{'='*70}")

        for category in categories:
            if category not in TEST_QUESTIONS:
                continue

            tests = TEST_QUESTIONS[category]
            if quick:
                tests = tests[:1]  # Only first test per category in quick mode

            for test in tests:
                total_tests += 1
                print(f"\n[{category.upper()}] {test['name']} ({test['difficulty']})")
                print("-" * 50)

                # Run the test
                result = call_model(
                    model["name"],
                    test["question"],
                    model["thinking_budget"],
                    test["timeout"]
                )

                # Evaluate
                evaluation = evaluate_response(result, test)

                # Print results
                if result["success"]:
                    print(f"[OK] Success in {result['elapsed']:.2f}s")
                    print(f"  Thinking: {result['thinking_length']} chars")
                    print(f"  Answer: {result['answer_length']} chars")
                    print(f"  Tokens: {result['input_tokens']} in / {result['output_tokens']} out")
                    print(f"  Score: {evaluation['score']:.0f}/100")
                    for reason in evaluation["reasons"]:
                        print(f"    {reason}")

                    model_results["total_score"] += evaluation["score"]
                    model_results["total_time"] += result["elapsed"]
                    model_results["total_tokens"] += result["output_tokens"]
                    model_results["success_count"] += 1
                else:
                    print(f"[FAIL] FAILED: {result.get('error', 'Unknown error')}")

                model_results["tests"].append({
                    "category": category,
                    "name": test["name"],
                    "difficulty": test["difficulty"],
                    "result": result,
                    "evaluation": evaluation,
                })

        results.append(model_results)

    # Print summary
    print("\n" + "=" * 70)
    print("BENCHMARK RESULTS SUMMARY")
    print("=" * 70)

    # Sort by score
    sorted_results = sorted(results, key=lambda x: x["total_score"], reverse=True)

    print(f"\n{'Model':<15} {'Score':>10} {'Avg Time':>10} {'Tokens':>10} {'Success':>10}")
    print("-" * 60)

    for r in sorted_results:
        avg_score = r["total_score"] / max(r["success_count"], 1)
        avg_time = r["total_time"] / max(r["success_count"], 1)
        print(f"{r['model']:<15} {r['total_score']:>10.0f} {avg_time:>9.2f}s {r['total_tokens']:>10} {r['success_count']:>10}")

    # Winner
    if sorted_results:
        winner = sorted_results[0]
        print(f"\n>>> BEST OVERALL: {winner['model']} (Score: {winner['total_score']:.0f})")

    # Detailed breakdown by category
    print("\n" + "=" * 70)
    print("BREAKDOWN BY CATEGORY")
    print("=" * 70)

    for category in categories:
        print(f"\n{category.upper()}:")
        cat_scores = {}
        for r in results:
            cat_tests = [t for t in r["tests"] if t["category"] == category]
            if cat_tests:
                cat_score = sum(t["evaluation"]["score"] for t in cat_tests if t["result"]["success"])
                cat_scores[r["model"]] = cat_score

        if cat_scores:
            for model, score in sorted(cat_scores.items(), key=lambda x: x[1], reverse=True):
                print(f"  {model}: {score:.0f}")

    # Save results to file
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"benchmark_results_{timestamp}.json"
    with open(filename, 'w') as f:
        json.dump({
            "timestamp": timestamp,
            "models_tested": models_to_test,
            "categories": categories,
            "results": results,
        }, f, indent=2)
    print(f"\nResults saved to: {filename}")

    return results


# ============================================================================
# MAIN
# ============================================================================

def main():
    import argparse

    parser = argparse.ArgumentParser(description='GLM Model Benchmark Suite')
    parser.add_argument('--quick', action='store_true', help='Quick test (fewer questions)')
    parser.add_argument('--coding', action='store_true', help='Only coding tests')
    parser.add_argument('--math', action='store_true', help='Only math tests')
    parser.add_argument('--reasoning', action='store_true', help='Only reasoning tests')
    parser.add_argument('--writing', action='store_true', help='Only writing tests')
    parser.add_argument('--models', type=str, help='Comma-separated list of models to test')

    args = parser.parse_args()

    # Determine categories
    categories = []
    if args.coding:
        categories.append("coding")
    if args.math:
        categories.append("math")
    if args.reasoning:
        categories.append("reasoning")
    if args.writing:
        categories.append("writing")
    if not categories:
        categories = None  # All categories

    # Determine models
    models = None
    if args.models:
        models = [m.strip() for m in args.models.split(",")]

    run_benchmark(models_to_test=models, categories=categories, quick=args.quick)


if __name__ == "__main__":
    main()
