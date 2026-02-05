#!/usr/bin/env python3
"""
Master Build Script for VMU Pro Test Applications

This script builds all test applications in order, creating .vmupack files
that can be deployed to the VMU Pro device.

Usage:
    python build_all_tests.py [--skip-existing] [--clean]

Options:
    --skip-existing    Skip building if .vmupack file already exists
    --clean            Remove all .vmupack files before building
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# Test configuration - order matters for incremental testing
TESTS = [
    {
        "name": "test_minimal",
        "entry_point": "test_minimal.lua",
        "metadata": "test_minimal_metadata.json",
        "description": "Minimal app structure test"
    },
    {
        "name": "test_stage1",
        "entry_point": "test_stage1.lua",
        "metadata": "test_stage1_metadata.json",
        "description": "Display and graphics primitives"
    },
    {
        "name": "test_stage2",
        "entry_point": "test_stage2.lua",
        "metadata": "test_stage2_metadata.json",
        "description": "Input handling and button states"
    },
    {
        "name": "test_stage3",
        "entry_point": "test_stage3.lua",
        "metadata": "test_stage3_metadata.json",
        "description": "Sprite system and animation"
    },
    {
        "name": "test_stage4",
        "entry_point": "test_stage4.lua",
        "metadata": "test_stage4_metadata.json",
        "description": "Audio system and sound playback"
    },
    {
        "name": "test_stage5",
        "entry_point": "test_stage5.lua",
        "metadata": "test_stage5_metadata.json",
        "description": "Memory management and system utilities"
    },
    {
        "name": "test_stage6",
        "entry_point": "test_stage6.lua",
        "metadata": "test_stage6_metadata.json",
        "description": "Full integration test (Tamagotchi)"
    }
]

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
TESTS_DIR = PROJECT_ROOT / "examples" / "tests"
PACKER_SCRIPT = SCRIPT_DIR / "packer.py"
DEFAULT_ICON = SCRIPT_DIR / "default_icon.bmp"
OUTPUT_DIR = SCRIPT_DIR / "build"


def print_header(text):
    """Print a formatted header."""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70)


def print_section(text):
    """Print a formatted section."""
    print(f"\n{text}")
    print("-" * len(text))


def check_dependencies():
    """Check if required files exist."""
    print_section("Checking dependencies...")

    if not PACKER_SCRIPT.exists():
        print(f"ERROR: Packer script not found: {PACKER_SCRIPT}")
        return False

    if not DEFAULT_ICON.exists():
        print(f"WARNING: Default icon not found: {DEFAULT_ICON}")

    if not TESTS_DIR.exists():
        print(f"ERROR: Tests directory not found: {TESTS_DIR}")
        return False

    print("Dependencies OK")
    return True


def clean_builds():
    """Remove all existing .vmupack files."""
    print_section("Cleaning existing builds...")

    if OUTPUT_DIR.exists():
        vmupack_files = list(OUTPUT_DIR.glob("*.vmupack"))
        if vmupack_files:
            for file in vmupack_files:
                file.unlink()
                print(f"  Removed: {file.name}")
            print(f"Removed {len(vmupack_files)} file(s)")
        else:
            print("No existing builds found")
    else:
        print("Build directory does not exist yet")


def build_test(test_config, skip_existing=False):
    """Build a single test application."""
    test_name = test_config["name"]
    description = test_config["description"]

    print(f"\n[{test_config['entry_point']}]")
    print(f"  Description: {description}")

    # Check if test files exist
    test_lua = TESTS_DIR / test_config["entry_point"]
    test_metadata = TESTS_DIR / test_config["metadata"]

    if not test_lua.exists():
        print(f"  ERROR: Test file not found: {test_lua}")
        return False

    if not test_metadata.exists():
        print(f"  ERROR: Metadata file not found: {test_metadata}")
        return False

    # Check if output already exists
    output_file = OUTPUT_DIR / f"{test_name}.vmupack"
    if skip_existing and output_file.exists():
        print(f"  SKIPPED: Output file already exists")
        return True

    # Create output directory
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Build packer command
    cmd = [
        sys.executable,
        str(PACKER_SCRIPT),
        "--projectdir", str(TESTS_DIR),
        "--appname", test_name,
        "--meta", test_config["metadata"],
        "--sdkversion", "1.0.0"
    ]

    # Add icon if it exists
    if DEFAULT_ICON.exists():
        cmd.extend(["--icon", str(DEFAULT_ICON)])

    # Run packer
    print(f"  Building...")
    try:
        result = subprocess.run(
            cmd,
            cwd=SCRIPT_DIR,
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            # Check if output file was created
            expected_output = SCRIPT_DIR / f"{test_name}.vmupack"
            if expected_output.exists():
                # Move to output directory
                import shutil
                shutil.move(str(expected_output), str(output_file))
                print(f"  SUCCESS: {output_file.name}")
                return True
            else:
                print(f"  ERROR: Expected output file not created")
                print(f"  stdout: {result.stdout}")
                print(f"  stderr: {result.stderr}")
                return False
        else:
            print(f"  ERROR: Build failed with code {result.returncode}")
            print(f"  stdout: {result.stdout}")
            print(f"  stderr: {result.stderr}")
            return False

    except subprocess.TimeoutExpired:
        print(f"  ERROR: Build timed out")
        return False
    except Exception as e:
        print(f"  ERROR: {e}")
        return False


def main():
    """Main build function."""
    parser = argparse.ArgumentParser(
        description="Build all VMU Pro test applications",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python build_all_tests.py              # Build all tests
  python build_all_tests.py --skip-existing  # Skip already built tests
  python build_all_tests.py --clean      # Clean and rebuild all
        """
    )

    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Skip building if .vmupack file already exists"
    )

    parser.add_argument(
        "--clean",
        action="store_true",
        help="Remove all .vmupack files before building"
    )

    args = parser.parse_args()

    print_header("VMU Pro Test Applications Build Script")

    # Check dependencies
    if not check_dependencies():
        print("\nFATAL: Dependency check failed")
        sys.exit(1)

    # Clean if requested
    if args.clean:
        clean_builds()

    # Build all tests
    print_header("Building Test Applications")

    results = {
        "success": [],
        "failed": [],
        "skipped": []
    }

    for i, test_config in enumerate(TESTS, 1):
        print(f"\n[{i}/{len(TESTS)}] Building: {test_config['name']}")

        success = build_test(test_config, args.skip_existing)

        if success:
            output_file = OUTPUT_DIR / f"{test_config['name']}.vmupack"
            if args.skip_existing and output_file.exists():
                # Check if it was built or skipped
                # (build_test returns True for both cases)
                # We need to check the file modification time or add a flag
                pass
            results["success"].append(test_config["name"])
        else:
            results["failed"].append(test_config["name"])

    # Print summary
    print_header("Build Summary")

    print(f"\nTotal tests: {len(TESTS)}")
    print(f"  Successful: {len(results['success'])}")
    print(f"  Failed:     {len(results['failed'])}")

    if results["success"]:
        print("\nSuccessful builds:")
        for name in results["success"]:
            output_file = OUTPUT_DIR / f"{name}.vmupack"
            size = output_file.stat().st_size if output_file.exists() else 0
            print(f"  {name:20} {size:>6} bytes")

    if results["failed"]:
        print("\nFailed builds:")
        for name in results["failed"]:
            print(f"  {name}")

    # Print deployment instructions
    print_header("Deployment Instructions")

    print("\nTo deploy a test to your VMU Pro device:")
    print("  cd", SCRIPT_DIR)
    print("  python send.py \\")
    print("    --func send \\")
    print("    --localfile build/<test_name>.vmupack \\")
    print("    --remotefile apps/<test_name>.vmupack \\")
    print("    --comport <YOUR_COM_PORT>")

    print("\nExample:")
    print("  python send.py \\")
    print("    --func send \\")
    print("    --localfile build/test_minimal.vmupack \\")
    print("    --remotefile apps/test_minimal.vmupack \\")
    print("    --comport COM3")

    # Exit with appropriate code
    if results["failed"]:
        print("\nBuild completed with errors")
        sys.exit(1)
    else:
        print("\nAll tests built successfully!")
        sys.exit(0)


if __name__ == "__main__":
    main()
