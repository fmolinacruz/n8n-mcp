# Git Branching Strategy - Quick Start Guide

This is a one-page quick reference for the n8n-mcp Git branching strategy.

---

## 🚨 **CRITICAL POLICY**

**NO client code commits to main branch**

All client work must go to dedicated branches:
- WDL → `client/wdl/*`
- Villakuyaya → `client/villakuyaya/*`

---

## Branch Naming Rules

**Format:** `{type}/{scope}/{description}`

### Types
- `feature/` - New functionality
- `fix/` - Bug fixes  
- `hotfix/` - Critical production fixes
- `client/` - Client-specific work

### Examples
✅ `feature/auth/add-oauth-support`  
✅ `fix/api/handle-timeout-errors`  
✅ `client/wdl/custom-workflow`  
❌ `my-branch` (no type)  
❌ `test` (too vague)

---

## Common Workflows

### Core Feature Development
```bash
git checkout main
git pull origin main
git checkout -b feature/scope/description
# ... make changes ...
git push origin feature/scope/description
# Create PR to main (requires 2 reviews)
```

### WDL Client Work
```bash
git checkout client/wdl/main
git pull origin client/wdl/main
git checkout -b client/wdl/feature/description
# ... make changes ...
git push origin client/wdl/feature/description
# Create PR to client/wdl/main (requires 1 review)
```

### Bug Fix
```bash
git checkout main  # or client branch
git pull
git checkout -b fix/scope/bug-description
# ... fix bug ...
git push origin fix/scope/bug-description
# Create PR (requires review)
```

---

## Security - Pre-commit Hook

**Install the hook to prevent secret commits:**
```bash
./operations/scripts/pre-commit-secret-check.sh --install
```

**What it detects:**
- API keys and tokens
- Passwords
- AWS credentials
- GitHub tokens
- Private keys

**If blocked:** Review your changes and remove secrets. Use environment variables instead.

---

## Branch Protection

All protected branches require:
- ✅ Pull request reviews
- ✅ Passing status checks (tests, secret detection)
- ✅ No direct pushes
- ✅ No force pushes

**Main branch:** Requires 2 reviews  
**Client branches:** Requires 1 review

---

## Getting Help

**Issue** | **Contact**
----------|------------
Branch naming | Check examples above or [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)
Access denied | Your team lead
Security issue | Security team
Git problems | Development team

---

## Quick Commands

```bash
# Install pre-commit hook
./operations/scripts/pre-commit-secret-check.sh --install

# Test pre-commit hook
./operations/scripts/test-pre-commit-hook.sh

# Setup branches (team leads only)
./operations/scripts/setup-git-strategy.ps1

# Rename wrong branch
git branch -m old-name new-name
git push origin -d old-name
git push origin new-name
```

---

## Common Mistakes

**Mistake:** Pushing client code to main  
**Fix:** Move to client branch via cherry-pick

**Mistake:** Wrong branch name  
**Fix:** Rename branch (see commands above)

**Mistake:** Committed a secret  
**Fix:** Remove, rotate credential, notify security team

**Mistake:** Can't push (access denied)  
**Fix:** Create PR instead, you don't have direct push access

---

## Resources

📖 **Full Documentation:**
- [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md) - Complete guide
- [GIT_STRATEGY_EVALUATION.md](./GIT_STRATEGY_EVALUATION.md) - Strategy details
- [SECURITY.md](../../SECURITY.md) - Security policies

🔧 **Scripts:**
- `setup-git-strategy.ps1` - Branch setup
- `pre-commit-secret-check.sh` - Secret detection
- `test-pre-commit-hook.sh` - Hook testing

---

## Team Access

| Team | Branches | Permissions |
|------|----------|-------------|
| Core Dev | All branches | Read, Write, Admin |
| WDL | `client/wdl/*` | Read, Write |
| Villakuyaya | `client/villakuyaya/*` | Read, Write |

---

**Print this page and keep it handy!** 📄

For detailed information, see [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)
