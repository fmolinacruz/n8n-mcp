# Git Strategy Evaluation and Implementation Plan

## Executive Summary

This document outlines the approved Git branching strategy for n8n-mcp, incorporating security enhancements, client isolation, and historical data management.

## Status: APPROVED ✅

**Approved Elements:**
- Core branching strategy and client isolation approach
- Branch naming conventions: `{type}/{scope}/{description}`
- Protection rules framework
- Automated validation approach

**Date of Approval:** 2025-11-11  
**Stakeholders:** Development Team, Security Team, Director

---

## Branching Strategy Overview

### Branch Structure

```
main (protected)
├── client/wdl/* (protected, WDL team access)
├── client/villakuyaya/* (protected, Villakuyaya team access)
├── feature/{scope}/{description}
├── fix/{scope}/{description}
├── hotfix/{scope}/{description}
└── release/{version}
```

### Branch Naming Conventions

**Format:** `{type}/{scope}/{description}`

**Types:**
- `feature/` - New functionality
- `fix/` - Bug fixes
- `hotfix/` - Critical production fixes
- `release/` - Release branches
- `client/` - Client-specific work (protected)

**Examples:**
- `feature/auth/add-oauth-support`
- `fix/api/handle-timeout-errors`
- `client/wdl/custom-workflow`
- `client/villakuyaya/integration-updates`

---

## Security Enhancements

### 1. Historical Data Management

**Decision:** Accept historical data on main with risk mitigation (Option A - Recommended)

**Rationale:**
- Full history rewrite (Option B) is high-risk and disruptive
- Historical commits are already in version control history
- Cherry-picking moves changes but doesn't remove original commits
- Access controls and documentation provide adequate mitigation

**Mitigation Strategies:**
1. **Access Controls**: Restrict access to main branch via GitHub team permissions
2. **Documentation**: Maintain audit trail in HISTORICAL_DATA_REPORT.md
3. **Prevention**: All new client work strictly on `client/*` branches
4. **Review**: Mandatory code review for all merges to main

### 2. Secret Prevention

**Pre-commit Hooks:**
- Automated scanning for API keys, tokens, passwords
- Prevents commits containing sensitive data
- Located in: `operations/scripts/pre-commit-secret-check.sh`

**CI/CD Detection:**
- GitHub Actions workflow for secret scanning
- Runs on all push and pull request events
- Uses `git-secrets` or similar tools

### 3. Access Control

**Branch Protection Rules:**
- Main branch: Full protection, require reviews, no force push
- Client branches: Team-specific access, protection rules
- Feature branches: Standard workflow, merge via PR

**GitHub Team Permissions:**
- WDL Team → `client/wdl/*` branches (read/write)
- Villakuyaya Team → `client/villakuyaya/*` branches (read/write)
- Core Team → All branches (admin access)

---

## Implementation Timeline

### Phase 0: IMMEDIATE (1-2 days) 🚨

**Priority Actions:**
1. Lock down main branch protection on GitHub NOW
2. Team communication: "Effective immediately: NO client code commits to main"
3. Stakeholder review of this document with Director

**Validation:**
- ✅ Main branch protection active and verified
- ✅ Team notified of new policy
- ✅ Stakeholder approval documented

### Phase 1: Week 1

**Actions:**
1. Create client branches with protection rules
   - Run: `./operations/scripts/setup-git-strategy.ps1`
2. Configure GitHub team permissions
   - WDL team → `client/wdl/*`
   - Villakuyaya team → `client/villakuyaya/*`
3. Audit historical secrets
   - Run: `git log --all -p -S "NOTION_API_KEY" > operations/docs/secret_audit.txt`
4. Implement pre-commit hooks
   - Install: `operations/scripts/pre-commit-secret-check.sh`

**Validation:**
- ✅ New branches exist with protection rules
- ✅ Access controls configured
- ✅ Secret audit completed and reviewed
- ✅ Pre-commit hooks installed and tested

### Phase 2: Weeks 2-3 (possibly Week 4) ⚠️ HIGHEST RISK

**Cherry-picking Strategy:**
1. Identify active client commits
   ```bash
   git log --all --grep="WDL\|villakuyaya\|VK" --oneline > operations/docs/client_commits.txt
   ```

2. Dry run testing FIRST
   ```bash
   git checkout client/wdl/main
   git cherry-pick <commit-hash> --no-commit  # Test first
   git reset --hard  # If conflicts, abort
   ```

3. Document what remains on main
   - Update `operations/docs/HISTORICAL_DATA_REPORT.md`

**Risk Mitigation:**
- Allocate 50% of total project time to this phase
- Dry-run testing before actual cherry-picks
- Full backup before starting cherry-pick operations
- Thorough testing after each cherry-pick batch

**Validation:**
- ✅ Client features functional on dedicated branches
- ✅ Thorough testing completed
- ✅ Historical data documented
- ✅ No regression in existing functionality

### Phase 3: Week 4

**Automation and Training:**
1. GitHub Actions workflows active and passing
   - Branch validation: `.github/workflows/branch-validation.yml`
   - Secret detection: `.github/workflows/secret-detection.yml`

2. Documentation updates
   - Update README.md with branching strategy
   - Create BRANCHING_STRATEGY.md guide
   - Update CONTRIBUTING.md

3. Team training
   - Workshop on new branching strategy
   - Review of pre-commit hooks
   - Practice with cherry-picking workflow

**Validation:**
- ✅ All automated checks passing
- ✅ Documentation updated and reviewed
- ✅ Team trained on new workflow
- ✅ Dry-run successful with sample scenarios

---

## Total Timeline: 3-4 weeks minimum, potentially extending to 5 weeks

**Critical Path:** Phase 2 (cherry-picking) is the highest risk and requires the most time.

---

## Critical Security Considerations

### Gemini's Warning on Historical Data

> "Cherry-picking moves the changes, but the original commit history on main still contains the client data. For true data removal, a full history rewrite would be required, which is highly disruptive."

### Our Approach

**Accept:** Historical data remains on main branch  
**Mitigate:** Restrict access, enforce code review, document clearly  
**Prevent:** All new client work on `client/*` branches only

### Audit Trail

All historical client commits will be documented in:
- `operations/docs/HISTORICAL_DATA_REPORT.md`
- `operations/docs/secret_audit.txt`

### Access Restrictions

Main branch access limited to:
- Core development team (with review requirements)
- Automated deployment systems (read-only)
- No direct push access (PR merge only)

---

## Next Immediate Actions

1. ✅ Review Council feedback (this document)
2. 🚨 Phase 0 - Day 1: Set up main branch protection on GitHub
3. 📢 Phase 0 - Day 2: Communicate new policy to team
4. 🔧 Week 1: Execute revised Phase 1 with protection-first approach

---

## Implementation Philosophy

> **"Lock it down, then build within the confines"**

This approach ensures security is established first, then development proceeds within the protected framework.

---

## Approval Signatures

- **Development Team Lead:** _________________ Date: _______
- **Security Officer:** _________________ Date: _______
- **Project Director:** _________________ Date: _______

---

## Revision History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-11 | Initial approved version | Dev Team |

---

## References

- [SECURITY.md](../../SECURITY.md) - Security best practices
- [HISTORICAL_DATA_REPORT.md](./HISTORICAL_DATA_REPORT.md) - Audit trail
- [Branch Protection Setup Script](../scripts/setup-git-strategy.ps1)
- [Pre-commit Hook](../scripts/pre-commit-secret-check.sh)
