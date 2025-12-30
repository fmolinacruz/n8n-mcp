#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Sets up Git branching strategy with protection rules for n8n-mcp project.

.DESCRIPTION
    This script creates client-specific branches and documents the branch protection
    rules that need to be configured in GitHub. It does NOT directly configure GitHub
    settings, as those require manual setup through the GitHub UI or API with admin tokens.

.NOTES
    File Name      : setup-git-strategy.ps1
    Prerequisite   : Git must be installed and repository must be initialized
    Phase          : Phase 1 - Week 1
    
.EXAMPLE
    ./operations/scripts/setup-git-strategy.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBranchCreation = $false
)

# Script configuration
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Get-Item $ScriptDir).Parent.Parent.FullName

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Git Branching Strategy Setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if we're in a git repository
function Test-GitRepository {
    try {
        $null = git rev-parse --git-dir 2>&1
        return $true
    } catch {
        return $false
    }
}

# Function to create a branch if it doesn't exist
function New-GitBranch {
    param(
        [string]$BranchName,
        [switch]$DryRun
    )
    
    $exists = git branch --list $BranchName
    
    if ($exists) {
        Write-Host "  ✓ Branch '$BranchName' already exists" -ForegroundColor Yellow
        return $false
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create branch: $BranchName" -ForegroundColor Cyan
        return $true
    }
    
    try {
        git branch $BranchName
        Write-Host "  ✓ Created branch: $BranchName" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  ✗ Failed to create branch: $BranchName" -ForegroundColor Red
        Write-Host "    Error: $_" -ForegroundColor Red
        return $false
    }
}

# Verify we're in a Git repository
Write-Host "Step 1: Verifying Git repository..." -ForegroundColor Cyan
if (-not (Test-GitRepository)) {
    Write-Host "✗ Not in a Git repository. Please run this script from the repository root." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Git repository verified" -ForegroundColor Green
Write-Host ""

# Get current branch
$currentBranch = git branch --show-current
Write-Host "Current branch: $currentBranch" -ForegroundColor Yellow
Write-Host ""

# Define client branches to create
$clientBranches = @(
    @{
        Name = "client/wdl/main"
        Team = "WDL Team"
        Description = "Main branch for WDL client work"
    },
    @{
        Name = "client/wdl/development"
        Team = "WDL Team"
        Description = "Development branch for WDL client"
    },
    @{
        Name = "client/villakuyaya/main"
        Team = "Villakuyaya Team"
        Description = "Main branch for Villakuyaya client work"
    },
    @{
        Name = "client/villakuyaya/development"
        Team = "Villakuyaya Team"
        Description = "Development branch for Villakuyaya client"
    }
)

# Create branches
if (-not $SkipBranchCreation) {
    Write-Host "Step 2: Creating client branches..." -ForegroundColor Cyan
    
    $branchesCreated = 0
    foreach ($branch in $clientBranches) {
        if (New-GitBranch -BranchName $branch.Name -DryRun:$DryRun) {
            $branchesCreated++
        }
    }
    
    Write-Host ""
    Write-Host "Summary: $branchesCreated new branch(es) created" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Step 2: Skipping branch creation (--SkipBranchCreation)" -ForegroundColor Yellow
    Write-Host ""
}

# Generate branch protection documentation
Write-Host "Step 3: Generating branch protection configuration..." -ForegroundColor Cyan

$protectionDoc = @"
# Branch Protection Rules Configuration

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

This document contains the branch protection rules that must be configured manually
in GitHub. These rules cannot be automatically applied via this script and require
repository admin access through the GitHub web interface or API.

## How to Apply These Rules

1. Navigate to: https://github.com/[OWNER]/[REPO]/settings/branches
2. Click "Add rule" for each branch pattern below
3. Configure the protection settings as specified

---

## Main Branch Protection

**Branch name pattern:** `main`

### Settings:
- ✅ Require pull request reviews before merging
  - Required approving reviews: 2
  - Dismiss stale pull request approvals when new commits are pushed
  - Require review from Code Owners
  
- ✅ Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Status checks required:
    - `test` (from GitHub Actions)
    - `secret-detection` (from GitHub Actions)
    - `branch-validation` (from GitHub Actions)
    
- ✅ Require conversation resolution before merging

- ✅ Require signed commits

- ✅ Require linear history

- ✅ Include administrators (enforce for admins too)

- ✅ Restrict who can push to matching branches
  - Allow only: Core Development Team (GitHub team)
  
- ✅ Allow force pushes: DISABLED

- ✅ Allow deletions: DISABLED

---

## Client Branch Protection

### WDL Client Branches

**Branch name pattern:** `client/wdl/*`

### Settings:
- ✅ Require pull request reviews before merging
  - Required approving reviews: 1
  - Dismiss stale pull request approvals when new commits are pushed
  
- ✅ Require status checks to pass before merging
  - Status checks required:
    - `test`
    - `secret-detection`
    
- ✅ Require conversation resolution before merging

- ✅ Restrict who can push to matching branches
  - Allow: WDL Team (GitHub team)
  
- ✅ Allow force pushes: DISABLED

- ✅ Allow deletions: DISABLED (except for feature branches)

---

### Villakuyaya Client Branches

**Branch name pattern:** `client/villakuyaya/*`

### Settings:
- ✅ Require pull request reviews before merging
  - Required approving reviews: 1
  - Dismiss stale pull request approvals when new commits are pushed
  
- ✅ Require status checks to pass before merging
  - Status checks required:
    - `test`
    - `secret-detection`
    
- ✅ Require conversation resolution before merging

- ✅ Restrict who can push to matching branches
  - Allow: Villakuyaya Team (GitHub team)
  
- ✅ Allow force pushes: DISABLED

- ✅ Allow deletions: DISABLED (except for feature branches)

---

## Feature and Fix Branches

**Branch name pattern:** `feature/*` and `fix/*`

### Settings:
- ✅ Require pull request reviews before merging
  - Required approving reviews: 1
  
- ✅ Require status checks to pass before merging
  - Status checks required:
    - `test`
    - `secret-detection`
    
- ✅ Allow force pushes: DISABLED

- ✅ Allow deletions: ENABLED (for cleanup after merge)

---

## GitHub Team Configuration

You must also configure GitHub teams with appropriate access:

### Core Development Team
- **Access Level:** Maintain or Admin
- **Branches:** All branches (via branch protection rules)
- **Members:** [List core developers]

### WDL Team
- **Access Level:** Write
- **Branches:** `client/wdl/*` only
- **Members:** [List WDL team members]

### Villakuyaya Team
- **Access Level:** Write
- **Branches:** `client/villakuyaya/*` only
- **Members:** [List Villakuyaya team members]

---

## Verification Checklist

After configuring branch protection rules:

- [ ] Main branch protection is active
- [ ] Test push to main fails (should require PR)
- [ ] Client branch protection is active for WDL
- [ ] Client branch protection is active for Villakuyaya
- [ ] GitHub teams are configured
- [ ] Team members can access their respective branches
- [ ] Force push is disabled on all protected branches
- [ ] Status checks are required and passing

---

## Notes

- Branch protection rules require repository admin privileges
- Some features (like required status checks) require GitHub Actions workflows to be set up first
- Review and adjust settings based on team size and workflow requirements
- Document any deviations from these recommendations

"@

$protectionDocPath = Join-Path $RepoRoot "operations/docs/BRANCH_PROTECTION_RULES.md"

if ($DryRun) {
    Write-Host "[DRY RUN] Would write branch protection documentation to:" -ForegroundColor Cyan
    Write-Host "  $protectionDocPath" -ForegroundColor Cyan
} else {
    $protectionDoc | Out-File -FilePath $protectionDocPath -Encoding UTF8
    Write-Host "✓ Branch protection documentation written to:" -ForegroundColor Green
    Write-Host "  $protectionDocPath" -ForegroundColor Green
}

Write-Host ""

# Generate team communication template
Write-Host "Step 4: Generating team communication template..." -ForegroundColor Cyan

$teamComm = @"
# Team Communication: New Git Branching Strategy

**Subject:** IMPORTANT: New Git Branching Strategy - Effective Immediately

**Date:** $(Get-Date -Format "yyyy-MM-dd")

---

## Summary

Effective immediately, we are implementing a new Git branching strategy to improve code organization and security. Please read this carefully.

## ⚠️ CRITICAL POLICY CHANGE

**NO client code commits to main branch**

All client-specific work must now be committed to dedicated client branches:
- WDL Team → `client/wdl/*` branches
- Villakuyaya Team → `client/villakuyaya/*` branches

## What This Means For You

### If you work on WDL projects:
1. Create feature branches from `client/wdl/main`
2. Name your branches: `client/wdl/feature/{description}`
3. Merge back to `client/wdl/main` via pull request

### If you work on Villakuyaya projects:
1. Create feature branches from `client/villakuyaya/main`
2. Name your branches: `client/villakuyaya/feature/{description}`
3. Merge back to `client/villakuyaya/main` via pull request

### If you work on core n8n-mcp features:
1. Create feature branches from `main`
2. Name your branches: `feature/{scope}/{description}`
3. Merge back to `main` via pull request

## Branch Naming Examples

✅ **Good:**
- `client/wdl/feature/add-custom-workflow`
- `client/villakuyaya/fix/api-timeout`
- `feature/auth/oauth-support`
- `fix/api/error-handling`

❌ **Bad:**
- `wdl-feature` (missing client prefix)
- `my-branch` (not descriptive)
- `test` (too generic)

## New Pre-Commit Hooks

A pre-commit hook has been installed to prevent accidental commits of sensitive data:
- API keys
- Tokens
- Passwords
- Client secrets

If your commit is blocked, review your changes and remove any sensitive data.

## Branch Protection

The following branches are now protected and require pull requests:
- `main` - Requires 2 approvals
- `client/wdl/*` - Requires 1 approval
- `client/villakuyaya/*` - Requires 1 approval

You cannot push directly to these branches.

## Timeline

- **Today:** New policy in effect, branch protection active
- **This Week:** Client branches created, pre-commit hooks installed
- **Next 2-3 Weeks:** Migration of existing client code to new branches
- **Week 4:** Training and documentation finalized

## Questions?

Contact:
- Technical questions: [Dev Team Lead]
- Access issues: [GitHub Admin]
- Policy clarification: [Project Director]

## Resources

- [GIT_STRATEGY_EVALUATION.md](./operations/docs/GIT_STRATEGY_EVALUATION.md) - Full strategy document
- [BRANCH_PROTECTION_RULES.md](./operations/docs/BRANCH_PROTECTION_RULES.md) - Protection rules
- [SECURITY.md](./SECURITY.md) - Security best practices

---

Thank you for your cooperation in implementing these important security and organizational improvements.

"@

$teamCommPath = Join-Path $RepoRoot "operations/docs/TEAM_COMMUNICATION_TEMPLATE.md"

if ($DryRun) {
    Write-Host "[DRY RUN] Would write team communication template to:" -ForegroundColor Cyan
    Write-Host "  $teamCommPath" -ForegroundColor Cyan
} else {
    $teamComm | Out-File -FilePath $teamCommPath -Encoding UTF8
    Write-Host "✓ Team communication template written to:" -ForegroundColor Green
    Write-Host "  $teamCommPath" -ForegroundColor Green
}

Write-Host ""

# Summary
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes were made" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Review the branch protection documentation:" -ForegroundColor White
Write-Host "   $protectionDocPath" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Manually configure branch protection rules on GitHub:" -ForegroundColor White
Write-Host "   https://github.com/[OWNER]/[REPO]/settings/branches" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Configure GitHub teams and permissions:" -ForegroundColor White
Write-Host "   https://github.com/[OWNER]/[REPO]/settings/access" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Install pre-commit hooks:" -ForegroundColor White
Write-Host "   ./operations/scripts/pre-commit-secret-check.sh --install" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Communicate changes to team:" -ForegroundColor White
Write-Host "   Review: $teamCommPath" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Run secret audit:" -ForegroundColor White
Write-Host "   See: operations/docs/HISTORICAL_DATA_REPORT.md" -ForegroundColor Gray
Write-Host ""

if (-not $DryRun -and -not $SkipBranchCreation) {
    Write-Host "Branches created:" -ForegroundColor Green
    foreach ($branch in $clientBranches) {
        Write-Host "  - $($branch.Name)" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "For questions or issues, refer to:" -ForegroundColor Cyan
Write-Host "  operations/docs/GIT_STRATEGY_EVALUATION.md" -ForegroundColor Gray
Write-Host ""
