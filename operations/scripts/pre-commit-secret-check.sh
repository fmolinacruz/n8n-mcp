#!/usr/bin/env bash
#
# Pre-commit hook for preventing secrets from being committed to the repository
#
# This script scans staged changes for potential secrets, API keys, tokens, and passwords.
# It prevents commits that contain sensitive data.
#
# Installation:
#   ./operations/scripts/pre-commit-secret-check.sh --install
#
# Manual execution:
#   ./operations/scripts/pre-commit-secret-check.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_PATH="$REPO_ROOT/.git/hooks/pre-commit"

# Function to print colored messages
print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Function to install the pre-commit hook
install_hook() {
    print_info "Installing pre-commit hook..."
    
    if [ ! -d "$REPO_ROOT/.git/hooks" ]; then
        print_error ".git/hooks directory not found. Are you in a Git repository?"
        exit 1
    fi
    
    if [ -f "$HOOK_PATH" ]; then
        print_warning "Pre-commit hook already exists."
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled."
            exit 0
        fi
        # Backup existing hook
        mv "$HOOK_PATH" "$HOOK_PATH.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Existing hook backed up."
    fi
    
    # Create symlink to this script
    ln -sf "$SCRIPT_DIR/pre-commit-secret-check.sh" "$HOOK_PATH"
    chmod +x "$HOOK_PATH"
    
    print_success "Pre-commit hook installed successfully!"
    print_info "Location: $HOOK_PATH"
    exit 0
}

# Function to uninstall the pre-commit hook
uninstall_hook() {
    if [ ! -f "$HOOK_PATH" ]; then
        print_warning "No pre-commit hook found."
        exit 0
    fi
    
    rm "$HOOK_PATH"
    print_success "Pre-commit hook removed."
    
    # Restore backup if exists
    LATEST_BACKUP=$(ls -t "$HOOK_PATH.backup."* 2>/dev/null | head -1)
    if [ -n "$LATEST_BACKUP" ]; then
        read -p "Restore previous hook from backup? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$LATEST_BACKUP" "$HOOK_PATH"
            print_success "Previous hook restored."
        fi
    fi
    
    exit 0
}

# Check for installation/uninstallation flags
if [ "$1" == "--install" ]; then
    install_hook
elif [ "$1" == "--uninstall" ]; then
    uninstall_hook
elif [ "$1" == "--help" ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --install     Install this script as a Git pre-commit hook"
    echo "  --uninstall   Remove the pre-commit hook"
    echo "  --help        Show this help message"
    echo ""
    echo "Without options, runs the secret detection on staged changes."
    exit 0
fi

# Main secret detection logic
print_info "Scanning staged changes for secrets..."
echo ""

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    print_warning "No files staged for commit."
    exit 0
fi

# Patterns to search for (case-insensitive)
PATTERNS=(
    # API Keys and tokens
    "api[_-]?key['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    "apikey['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    "api[_-]?secret['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    
    # Access tokens
    "access[_-]?token['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    "auth[_-]?token['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    "bearer['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    
    # Passwords
    "password['\"]?\s*[:=]\s*['\"]?[^'\"\s]{8,}"
    "passwd['\"]?\s*[:=]\s*['\"]?[^'\"\s]{8,}"
    "pwd['\"]?\s*[:=]\s*['\"]?[^'\"\s]{8,}"
    
    # Database URLs with credentials
    "://[^:@\s]+:[^:@\s]+@"
    
    # AWS keys
    "AKIA[0-9A-Z]{16}"
    "aws[_-]?access[_-]?key[_-]?id['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9]{20}"
    "aws[_-]?secret[_-]?access[_-]?key['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9/+]{40}"
    
    # GitHub tokens
    "gh[ps]_[A-Za-z0-9_]{36,}"
    
    # Private keys
    "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
    
    # Generic secrets
    "secret['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    "token['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    
    # n8n specific
    "n8n[_-]?api[_-]?key['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
    "notion[_-]?api[_-]?key['\"]?\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{20,}"
)

# Files and patterns to exclude (reduce false positives)
EXCLUDE_PATTERNS=(
    "\.md$"  # Documentation files (but still scan for real keys)
    "\.md:.*example"  # Example keys in documentation
    "\.md:.*placeholder"  # Placeholder keys in documentation
    "\.md:.*your-api-key-here"  # Template keys
    "\.env\.example"  # Example env files
    "\.env\.test\.example"  # Example test env files
    "test.*\.ts"  # Test files with mock data
    "test.*\.js"  # Test files with mock data
)

# Function to check if line should be excluded
should_exclude() {
    local file_line="$1"
    for exclude_pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if echo "$file_line" | grep -qiE "$exclude_pattern"; then
            # Additional check: if it contains "example", "placeholder", "fake", or "mock"
            if echo "$file_line" | grep -qiE "(example|placeholder|fake|mock|test|dummy|sample)"; then
                return 0  # Exclude this line
            fi
        fi
    done
    return 1  # Don't exclude
}

# Function to check if a match is a false positive
is_false_positive() {
    local line="$1"
    
    # Common false positive patterns
    FALSE_POSITIVE_PATTERNS=(
        "\.example"
        "placeholder"
        "your-.*-here"
        "xxx"
        "abc123"
        "test"
        "sample"
        "dummy"
        "fake"
        "mock"
        "TODO"
        "FIXME"
        "# Example:"
        "// Example:"
    )
    
    for fp_pattern in "${FALSE_POSITIVE_PATTERNS[@]}"; do
        if echo "$line" | grep -qiE "$fp_pattern"; then
            return 0  # Is a false positive
        fi
    done
    
    return 1  # Not a false positive
}

FOUND_SECRETS=0
WARNINGS=0

# Scan each staged file
for file in $STAGED_FILES; do
    # Skip deleted files
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # Get the staged content
    STAGED_CONTENT=$(git diff --cached "$file")
    
    # Check against each pattern
    for pattern in "${PATTERNS[@]}"; do
        MATCHES=$(echo "$STAGED_CONTENT" | grep -niE "$pattern" || true)
        
        if [ -n "$MATCHES" ]; then
            while IFS= read -r match; do
                FILE_LINE="$file:$match"
                
                # Skip if should be excluded
                if should_exclude "$FILE_LINE"; then
                    continue
                fi
                
                # Check if it's a false positive
                if is_false_positive "$match"; then
                    ((WARNINGS++))
                    print_warning "Possible secret (likely false positive) in $file:"
                    echo "  $match"
                    echo ""
                else
                    ((FOUND_SECRETS++))
                    print_error "Potential secret found in $file:"
                    echo "  $match"
                    echo ""
                fi
            done <<< "$MATCHES"
        fi
    done
done

echo ""
echo "=================================="
echo "Scan Results:"
echo "=================================="
echo "Files scanned: $(echo "$STAGED_FILES" | wc -l)"
echo "Potential secrets found: $FOUND_SECRETS"
echo "Warnings (likely false positives): $WARNINGS"
echo ""

# Decision
if [ $FOUND_SECRETS -gt 0 ]; then
    print_error "COMMIT REJECTED: Potential secrets detected in staged changes."
    echo ""
    echo "If these are false positives, you can:"
    echo "  1. Add example/placeholder indicators to the values"
    echo "  2. Move secrets to .env files (already in .gitignore)"
    echo "  3. Use environment variables instead of hardcoded values"
    echo ""
    echo "To bypass this check (NOT RECOMMENDED):"
    echo "  git commit --no-verify"
    echo ""
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    print_warning "Warnings detected but commit allowed."
    echo ""
    echo "Please review the warnings above and ensure no real secrets are being committed."
    echo ""
    exit 0
else
    print_success "No secrets detected. Commit allowed."
    exit 0
fi
