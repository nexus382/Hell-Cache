#!/usr/bin/env python3
"""
GLM-5 Deep Thinking Mode Test Script (Anthropic API compatible)
================================================================
For use with Z.AI / Zhipu GLM-5 via Anthropic-compatible endpoint.

Usage:
  python test_glm_thinking.py "Your question here"
  python test_glm_thinking.py  # Uses default test question
"""

import requests
import json
import sys
import os

# ============================================================================
# CONFIGURATION
# ============================================================================
API_KEY = os.getenv("ZHIPU_API_KEY", "8e3a3bdd1d2c45cb8ccecadfa73c01e9.xSlaPFASF4iSFQOV")
BASE_URL = os.getenv("ZHIPU_BASE_URL", "https://api.z.ai/api/anthropic")
MODEL = os.getenv("ZHIPU_MODEL", "GLM-5")

# Thinking mode settings
ENABLE_THINKING = True
MAX_THINKING_TOKENS = 131999  # From your settings.json
MAX_TOKENS = 8192

# Default test question
DEFAULT_QUESTION = """
Prove that for any positive integer n, the number n³ - n is always divisible by 6.
Show your complete reasoning.
"""

# ============================================================================
# MAIN FUNCTION
# ============================================================================

def call_glm_thinking(question: str, show_thinking: bool = True):
    """
    Call GLM-5 with thinking mode enabled using Anthropic-compatible API.
    """
    url = f"{BASE_URL}/v1/messages"

    headers = {
        "Content-Type": "application/json",
        "x-api-key": API_KEY,
        "anthropic-version": "2023-06-01"
    }

    # Build the request body
    payload = {
        "model": MODEL,
        "max_tokens": MAX_TOKENS,
        "messages": [
            {"role": "user", "content": question}
        ]
    }

    # Enable extended thinking (Anthropic format)
    if ENABLE_THINKING:
        payload["thinking"] = {
            "type": "enabled",
            "budget_tokens": MAX_THINKING_TOKENS
        }

    if show_thinking:
        print(f"\n{'='*60}")
        print(f"MODEL: {MODEL}")
        print(f"THINKING MODE: {'ON' if ENABLE_THINKING else 'OFF'}")
        print(f"THINKING BUDGET: {MAX_THINKING_TOKENS} tokens")
        print(f"{'='*60}\n")
        print(f"Question: {question.strip()}\n")
        print("=" * 20 + " API REQUEST " + "=" * 20)
        print(f"URL: {url}")
        print(f"Payload: {json.dumps(payload, indent=2)}\n")

    # Make the API call
    try:
        response = requests.post(url, headers=headers, json=payload, timeout=120)

        if show_thinking:
            print("=" * 20 + " API RESPONSE " + "=" * 20)
            print(f"Status: {response.status_code}")
            print(f"Headers: {dict(response.headers)}\n")

        if response.status_code != 200:
            print(f"ERROR: {response.status_code}")
            print(f"Response: {response.text}")
            return None, None, None

        data = response.json()

        if show_thinking:
            print("=" * 20 + " RAW RESPONSE " + "=" * 20)
            print(json.dumps(data, indent=2))
            print()

        # Parse the response
        thinking_content = ""
        answer_content = ""

        # Anthropic response format has content as a list of blocks
        if "content" in data:
            for block in data["content"]:
                if block.get("type") == "thinking":
                    thinking_content = block.get("thinking", "")
                    if show_thinking:
                        print("=" * 20 + " THINKING PROCESS " + "=" * 20 + "\n")
                        print(thinking_content)
                        print()
                elif block.get("type") == "text":
                    answer_content = block.get("text", "")
                    if show_thinking:
                        print("=" * 20 + " FINAL ANSWER " + "=" * 20 + "\n")
                        print(answer_content)

        # Usage stats
        usage = data.get("usage", {})

        if show_thinking and usage:
            print("\n" + "=" * 20 + " TOKEN USAGE " + "=" * 20)
            print(f"  Input tokens:      {usage.get('input_tokens', 'N/A')}")
            print(f"  Output tokens:     {usage.get('output_tokens', 'N/A')}")
            if "cache_creation_input_tokens" in usage:
                print(f"  Cache creation:    {usage['cache_creation_input_tokens']}")
            if "cache_read_input_tokens" in usage:
                print(f"  Cache read:        {usage['cache_read_input_tokens']}")

        return thinking_content, answer_content, usage

    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return None, None, None


def test_with_openai_format(question: str):
    """
    Alternative: Try OpenAI-compatible endpoint at bigmodel.cn
    """
    url = "https://open.bigmodel.cn/api/paas/v4/chat/completions"

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }

    payload = {
        "model": "glm-5",
        "messages": [{"role": "user", "content": question}],
        "enable_thinking": True,
        "temperature": 1.0,
        "max_tokens": 8192,
        "stream": False
    }

    print(f"\n{'='*60}")
    print("TRYING OPENAI-COMPATIBLE ENDPOINT")
    print(f"{'='*60}\n")

    try:
        response = requests.post(url, headers=headers, json=payload, timeout=120)
        print(f"Status: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.json()
    except Exception as e:
        print(f"ERROR: {e}")
        return None


# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

def main():
    # Get question from command line or use default
    if len(sys.argv) > 1:
        question = " ".join(sys.argv[1:])
    else:
        question = DEFAULT_QUESTION
        print("No question provided. Using default test question...")

    # Try Anthropic-compatible endpoint first
    thinking, answer, usage = call_glm_thinking(question)

    # If that fails, try OpenAI-compatible endpoint
    if answer is None:
        print("\nAnthropic endpoint failed. Trying OpenAI-compatible endpoint...")
        test_with_openai_format(question)

    print("\n" + "=" * 60)
    print("TEST COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
