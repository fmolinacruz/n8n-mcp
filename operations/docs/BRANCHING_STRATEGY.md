# Branching Strategy Guide

## Overview

This document describes the Git branching strategy for the n8n-mcp project. It is designed to:
- Isolate client-specific work from core development
- Improve code security and reduce risk of secret exposure
- Enable parallel development across multiple teams
- Maintain clear separation of concerns

## Quick Reference

```
main (protected)
├── client/wdl/* (WDL team only)
├── client/villakuyaya/* (Villakuyaya team only)
├── feature/{scope}/{description}
├── fix/{scope}/{description}
├── hotfix/{scope}/{description}
└── release/{version}
```

---

## Branch Types

### 1. Main Branch

**Branch:** `main`

**Purpose:** Production-ready code for core n8n-mcp functionality

**Protection Rules:**
- ✅ Requires 2 pull request reviews
- ✅ Requires all status checks to pass
- ✅ No direct pushes allowed
- ✅ No force pushes
- ✅ No deletions
- ✅ Must be up-to-date with base branch

**Who can merge:** Core development team only

**⚠️ CRITICAL POLICY:** NO client-specific code on main branch

---

### 2. Client Branches

#### WDL Client

**Branch Pattern:** `client/wdl/*`

**Examples:**
- `client/wdl/main` - Main branch for WDL work
- `client/wdl/development` - Development branch
- `client/wdl/feature/custom-workflow` - Feature branches

**Protection Rules:**
- ✅ Requires 1 pull request review
- ✅ Requires status checks to pass
- ✅ No direct pushes to main branches
- ✅ No force pushes

**Who can access:** WDL team members only

**Workflow:**
1. Create feature branch from `client/wdl/main`
2. Develop your feature
3. Create PR to merge back to `client/wdl/main`
4. Get review from WDL team member
5. Merge after approval and passing checks

#### Villakuyaya Client

**Branch Pattern:** `client/villakuyaya/*`

**Examples:**
- `client/villakuyaya/main` - Main branch for Villakuyaya work
- `client/villakuyaya/development` - Development branch
- `client/villakuyaya/feature/api-integration` - Feature branches

**Protection Rules:**
- ✅ Requires 1 pull request review
- ✅ Requires status checks to pass
- ✅ No direct pushes to main branches
- ✅ No force pushes

**Who can access:** Villakuyaya team members only

**Workflow:** Same as WDL (see above)

---

### 3. Feature Branches

**Branch Pattern:** `feature/{scope}/{description}`

**Purpose:** New functionality for core n8n-mcp

**Examples:**
- `feature/auth/add-oauth-support`
- `feature/api/rate-limiting`
- `feature/mcp/new-tool`

**Workflow:**
1. Create from `main`
2. Develop feature
3. Create PR to `main`
4. Get 2 reviews
5. Merge after approval

**Naming Guidelines:**
- Use lowercase
- Use hyphens for spaces
- Be descriptive but concise
- Include scope (what area of code)

---

### 4. Fix Branches

**Branch Pattern:** `fix/{scope}/{description}`

**Purpose:** Bug fixes for non-critical issues

**Examples:**
- `fix/api/timeout-handling`
- `fix/database/connection-leak`
- `fix/ui/display-error`

**Workflow:**
1. Create from `main` or relevant client branch
2. Fix the bug
3. Add/update tests
4. Create PR
5. Get review(s) based on target branch
6. Merge after approval

---

### 5. Hotfix Branches

**Branch Pattern:** `hotfix/{scope}/{description}`

**Purpose:** Critical production fixes that need immediate deployment

**Examples:**
- `hotfix/security/credential-leak`
- `hotfix/api/production-crash`

**Workflow:**
1. Create from `main`
2. Fix critical issue
3. Create PR with "HOTFIX" label
4. Get expedited review
5. Merge and deploy immediately

**Priority:** Highest - can interrupt other work

---

### 6. Release Branches

**Branch Pattern:** `release/{version}`

**Purpose:** Prepare for a new production release

**Examples:**
- `release/2.11.0`
- `release/3.0.0`

**Workflow:**
1. Create from `main`
2. Final testing and bug fixes
3. Update version numbers
4. Update CHANGELOG
5. Create release tag
6. Merge back to `main`

---

## Branch Naming Rules

### Format

`{type}/{scope}/{description}`

### Type (required)

- `feature` - New functionality
- `fix` - Bug fixes
- `hotfix` - Critical fixes
- `release` - Release preparation
- `client` - Client-specific work

### Scope (required for feature/fix)

The area of the codebase affected:
- `auth` - Authentication/authorization
- `api` - API endpoints
- `database` - Database layer
- `mcp` - MCP server functionality
- `tools` - MCP tools
- `ui` - User interface
- `docs` - Documentation
- `ci` - CI/CD pipeline
- `security` - Security features

### Description (required)

Short, hyphenated description:
- Use lowercase
- Use hyphens instead of spaces
- Be specific but concise
- 3-5 words is ideal

### Examples

✅ **Good branch names:**
```
feature/auth/add-oauth-support
fix/api/handle-timeout-errors
client/wdl/custom-workflow
hotfix/security/patch-vulnerability
release/2.11.0
```

❌ **Bad branch names:**
```
my-branch (no type)
feature-1 (no scope, not descriptive)
test (too vague)
johnDoeFeature (not formatted correctly)
client-wdl (missing type separator)
```

---

## Workflow Examples

### Example 1: Adding a Core Feature

```bash
# 1. Start from main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/mcp/add-validation-tool

# 3. Make changes
# ... write code ...
git add .
git commit -m "Add new validation tool for MCP"

# 4. Push and create PR
git push origin feature/mcp/add-validation-tool

# 5. Create PR on GitHub targeting 'main'
# 6. Get 2 reviews
# 7. Merge via GitHub
```

### Example 2: WDL Client Work

```bash
# 1. Start from client main
git checkout client/wdl/main
git pull origin client/wdl/main

# 2. Create feature branch
git checkout -b client/wdl/feature/custom-notification

# 3. Make changes
# ... write code ...
git add .
git commit -m "Add custom notification workflow for WDL"

# 4. Push and create PR
git push origin client/wdl/feature/custom-notification

# 5. Create PR on GitHub targeting 'client/wdl/main'
# 6. Get 1 review from WDL team
# 7. Merge via GitHub
```

### Example 3: Bug Fix

```bash
# 1. Start from affected branch
git checkout main  # or client/wdl/main
git pull

# 2. Create fix branch
git checkout -b fix/api/connection-timeout

# 3. Fix the bug
# ... write fix ...
# ... add/update tests ...
git add .
git commit -m "Fix API connection timeout issue"

# 4. Push and create PR
git push origin fix/api/connection-timeout

# 5. Create PR and get review(s)
# 6. Merge via GitHub
```

---

## Pull Request Guidelines

### PR Title

Format: `[Type] Brief description`

Examples:
- `[Feature] Add OAuth authentication support`
- `[Fix] Handle API timeout errors`
- `[Hotfix] Patch security vulnerability`
- `[Client/WDL] Custom workflow implementation`

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Feature (new functionality)
- [ ] Fix (bug fix)
- [ ] Hotfix (critical fix)
- [ ] Documentation
- [ ] Refactoring
- [ ] Client-specific work

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] No tests required (documentation only)

## Checklist
- [ ] Code follows project style guidelines
- [ ] No secrets or sensitive data committed
- [ ] Documentation updated (if needed)
- [ ] All tests pass
- [ ] No merge conflicts

## Related Issues
Fixes #123
Related to #456
```

### Required Checks

All PRs must pass:
- ✅ Branch naming validation
- ✅ Secret detection scan
- ✅ Unit tests
- ✅ Integration tests (if applicable)
- ✅ Code review(s)

---

## Team Access Control

### Core Development Team

**Access:** All branches
**Permissions:** Read, Write, Admin (for main)
**Responsibilities:**
- Review all PRs to main
- Maintain branch protection rules
- Handle releases
- Code reviews for all teams

### WDL Team

**Access:** `client/wdl/*` branches only
**Permissions:** Read, Write
**Responsibilities:**
- WDL-specific development
- Review WDL team PRs
- Maintain WDL client code

### Villakuyaya Team

**Access:** `client/villakuyaya/*` branches only
**Permissions:** Read, Write
**Responsibilities:**
- Villakuyaya-specific development
- Review Villakuyaya team PRs
- Maintain Villakuyaya client code

---

## Security Guidelines

### Pre-commit Checks

A pre-commit hook scans for:
- API keys
- Tokens
- Passwords
- Hardcoded credentials

**Install the hook:**
```bash
./operations/scripts/pre-commit-secret-check.sh --install
```

### What to NEVER Commit

❌ **Never commit:**
- API keys or tokens
- Passwords
- Private keys
- `.env` files (not .example)
- Client-specific secrets
- Database credentials
- OAuth client secrets

✅ **Safe to commit:**
- `.env.example` (with placeholder values)
- Public configuration
- Documentation
- Test fixtures (with fake data)

### If You Accidentally Commit a Secret

1. **Immediately** notify the security team
2. **Rotate** the exposed credential
3. **Remove** the secret from git history (if needed)
4. **Document** the incident

---

## Common Scenarios

### Scenario: I need to work on a WDL feature

```bash
git checkout client/wdl/main
git pull
git checkout -b client/wdl/feature/my-feature
# ... develop ...
git push origin client/wdl/feature/my-feature
# Create PR to client/wdl/main
```

### Scenario: I found a bug in main

```bash
git checkout main
git pull
git checkout -b fix/scope/bug-description
# ... fix bug ...
git push origin fix/scope/bug-description
# Create PR to main
```

### Scenario: I need to make a hotfix

```bash
git checkout main
git pull
git checkout -b hotfix/scope/critical-issue
# ... fix issue ...
git push origin hotfix/scope/critical-issue
# Create PR with HOTFIX label
# Get expedited review
```

### Scenario: I'm on the wrong branch

```bash
# If you haven't committed yet
git stash
git checkout correct-branch
git stash pop

# If you've already committed
git log  # Note the commit SHA
git checkout correct-branch
git cherry-pick <commit-sha>
# Then reset the wrong branch
git checkout wrong-branch
git reset --hard HEAD~1
```

---

## Troubleshooting

### "Branch name doesn't follow convention"

**Cause:** Branch name doesn't match required pattern

**Solution:** Rename your branch
```bash
git branch -m old-name new-name
git push origin -d old-name  # Delete old remote branch
git push origin new-name
```

### "Pre-commit hook blocked my commit"

**Cause:** Potential secret detected

**Solution:** 
1. Review the flagged content
2. If it's a false positive, add "example" or "placeholder" marker
3. If it's a real secret, use environment variables instead

### "PR checks are failing"

**Cause:** One or more automated checks failed

**Solution:**
1. Check the GitHub Actions tab
2. Review the error messages
3. Fix the issues locally
4. Push the fixes
5. Checks will re-run automatically

### "I don't have permission to push"

**Cause:** Branch is protected or you don't have access

**Solution:**
1. Verify you're on the correct branch
2. Check with team lead if you need access
3. Create a PR instead of pushing directly

---

## References

- [GIT_STRATEGY_EVALUATION.md](./operations/docs/GIT_STRATEGY_EVALUATION.md) - Full implementation plan
- [SECURITY.md](./SECURITY.md) - Security best practices
- [HISTORICAL_DATA_REPORT.md](./operations/docs/HISTORICAL_DATA_REPORT.md) - Historical data audit
- [Pre-commit Hook](./operations/scripts/pre-commit-secret-check.sh) - Secret detection script

---

## Getting Help

**Questions about:**
- Branch naming → Check examples in this document
- Access issues → Contact your team lead
- Security concerns → Contact security team
- Git problems → Ask in team chat

**Resources:**
- Git documentation: https://git-scm.com/doc
- GitHub flow guide: https://guides.github.com/introduction/flow/
- Team Wiki: [Add your wiki link]

---

## Revision History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-11 | Initial version | Dev Team |

---

*This document is part of the n8n-mcp Git branching strategy implementation. For questions or suggestions, please contact the development team.*
