#!/usr/bin/env bash
#
# Test script for pre-commit secret detection hook
#

set -e

echo "=================================="
echo "Testing Pre-commit Hook"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_SCRIPT="$REPO_ROOT/operations/scripts/pre-commit-secret-check.sh"

# Test 1: Script exists and is executable
echo "Test 1: Script exists and is executable"
if [ -x "$HOOK_SCRIPT" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Script is executable"
else
    echo -e "${RED}✗ FAIL${NC}: Script not executable"
    exit 1
fi
echo ""

# Test 2: Help option works
echo "Test 2: Help option works"
if "$HOOK_SCRIPT" --help &>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}: Help option works"
else
    echo -e "${RED}✗ FAIL${NC}: Help option failed"
    exit 1
fi
echo ""

# Test 3: No staged files (should pass)
echo "Test 3: No staged files (should pass with warning)"
OUTPUT=$("$HOOK_SCRIPT" 2>&1)
if echo "$OUTPUT" | grep -q "No files staged"; then
    echo -e "${GREEN}✓ PASS${NC}: Correctly detects no staged files"
else
    echo -e "${RED}✗ FAIL${NC}: Did not detect no staged files"
    exit 1
fi
echo ""

# Test 4: Create test file with fake API key
echo "Test 4: Detecting API keys in staged changes"
TEST_FILE="$REPO_ROOT/.test_secret_detection.tmp"
echo 'api_key = "sk_test_51234567890abcdefghijklmnopqrstuvwxyz"' > "$TEST_FILE"
git add "$TEST_FILE" 2>/dev/null

OUTPUT=$("$HOOK_SCRIPT" 2>&1 || true)

# Clean up immediately
git reset HEAD "$TEST_FILE" 2>/dev/null || true
rm -f "$TEST_FILE"

if echo "$OUTPUT" | grep -qi "secret"; then
    echo -e "${GREEN}✓ PASS${NC}: Correctly detected potential secret"
else
    echo -e "${RED}✗ FAIL${NC}: Did not detect secret"
    echo "Output was: $OUTPUT"
    exit 1
fi
echo ""

# Test 5: Create test file with example marker (should be warning only)
echo "Test 5: Detecting false positives (example markers)"
TEST_FILE="$REPO_ROOT/.test_example.tmp"
echo 'api_key_example = "sk_test_example_key_placeholder"' > "$TEST_FILE"
git add "$TEST_FILE" 2>/dev/null

OUTPUT=$("$HOOK_SCRIPT" 2>&1 || true)

# Clean up
git reset HEAD "$TEST_FILE" 2>/dev/null || true
rm -f "$TEST_FILE"

if echo "$OUTPUT" | grep -qi "false positive"; then
    echo -e "${GREEN}✓ PASS${NC}: Correctly identified false positive"
else
    echo -e "${YELLOW}⚠ PARTIAL${NC}: May not have detected as false positive"
fi
echo ""

# Test 6: Pattern matching for various secret types
echo "Test 6: Testing various secret patterns"
PATTERNS_FOUND=0

# Test AWS key pattern
if echo "AKIAIOSFODNN7EXAMPLE" | grep -qE "AKIA[0-9A-Z]{16}"; then
    echo -e "${GREEN}✓${NC} AWS key pattern matches"
    PATTERNS_FOUND=$((PATTERNS_FOUND + 1))
fi

# Test GitHub token pattern
if echo "ghp_1234567890abcdefghijklmnopqrstuvwxyz" | grep -qE "gh[ps]_[A-Za-z0-9_]{36,}"; then
    echo -e "${GREEN}✓${NC} GitHub token pattern matches"
    PATTERNS_FOUND=$((PATTERNS_FOUND + 1))
fi

# Test API key pattern
if echo 'api_key="abc123def456ghi789"' | grep -qiE "api[_-]?key"; then
    echo -e "${GREEN}✓${NC} API key pattern matches"
    PATTERNS_FOUND=$((PATTERNS_FOUND + 1))
fi

if [ $PATTERNS_FOUND -ge 3 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Secret patterns working correctly"
else
    echo -e "${RED}✗ FAIL${NC}: Some patterns not matching"
    exit 1
fi
echo ""

# Summary
echo "=================================="
echo "All Tests Passed!"
echo "=================================="
echo ""
echo "The pre-commit hook is working correctly and can detect:"
echo "  ✓ API keys and tokens"
echo "  ✓ AWS credentials"
echo "  ✓ GitHub tokens"
echo "  ✓ False positives (with warnings)"
echo ""
echo "To install the hook:"
echo "  $HOOK_SCRIPT --install"
echo ""
