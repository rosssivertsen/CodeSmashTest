# CI/CD Pipeline Testing Guide

This guide explains how to test and validate the CI/CD pipeline templates before using them in production.

## Quick Start

### 1. Run Local Validation Tests

```bash
cd /Users/rosssivertsen/dev/enterprise-templates/test-project
./test-pipelines.sh
```

This will run 34 automated tests covering:
- Template file existence
- Branch configurations
- Deployment conditions
- Job dependencies
- Environment settings
- Branch management automation
- Quality gates
- GitHub Actions versions

### 2. Expected Output

```
======================================
CI/CD Pipeline Template Validator
======================================

✅ All 34 tests should pass
✅ 0 failures expected
```

## Testing in a Real Repository

To test the pipelines in an actual GitHub repository:

### Step 1: Create Test Repository

```bash
# Create new test repository
mkdir test-ci-cd-pipeline
cd test-ci-cd-pipeline
git init
git checkout -b main
```

### Step 2: Copy Template

Choose the appropriate template for your project type:

**For Node.js projects:**
```bash
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-template.yml .github/workflows/ci-cd.yml
```

**For Python projects:**
```bash
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-python-template.yml .github/workflows/ci-cd.yml
```

**For generic projects:**
```bash
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-generic-template.yml .github/workflows/ci-cd.yml
```

### Step 3: Add Validation Workflow

```bash
cp ~/dev/enterprise-templates/test-project/.github/workflows/validate-workflow.yml .github/workflows/
```

### Step 4: Create Minimal Project Files

**For Node.js:**
```bash
# Create package.json
cat > package.json << 'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "build": "echo 'Build successful'",
    "test": "echo 'Tests passed'",
    "lint": "echo 'Linting passed'"
  }
}
EOF

npm install
```

**For Python:**
```bash
# Create requirements.txt
echo "pytest==7.4.0" > requirements.txt

# Create simple test
mkdir tests
cat > tests/test_sample.py << 'EOF'
def test_sample():
    assert True
EOF
```

### Step 5: Create Branches

```bash
# Commit initial setup
git add .
git commit -m "Initial setup with CI/CD pipeline"

# Create development branch
git checkout -b development
git push origin development

# Create staging branch
git checkout -b staging
git push origin staging

# Push main
git checkout main
git push origin main
```

### Step 6: Configure GitHub Repository

1. Go to repository Settings → Environments
2. Create two environments:
   - `staging`
   - `production`
3. Optionally add approval requirements for production

### Step 7: Test Each Branch

**Test Development Branch:**
```bash
git checkout development
echo "# Development test" >> README.md
git add README.md
git commit -m "Test development branch deployment"
git push origin development
```

Expected behavior:
- Quality gates should run
- Staging deployment should trigger
- Production deployment should NOT trigger

**Test Staging Branch:**
```bash
git checkout staging
echo "# Staging test" >> README.md
git add README.md
git commit -m "Test staging branch deployment"
git push origin staging
```

Expected behavior:
- Quality gates should run
- Staging deployment should trigger
- Production deployment should NOT trigger

**Test Main Branch:**
```bash
git checkout main
echo "# Production test" >> README.md
git add README.md
git commit -m "Test production deployment"
git push origin main
```

Expected behavior:
- Quality gates should run
- Staging deployment should NOT trigger
- Production deployment should trigger
- Branch management should sync main → staging and main → development

## Validation Checklist

Use this checklist when testing pipelines:

### Branch Configuration
- [ ] Pipeline triggers on push to `main`
- [ ] Pipeline triggers on push to `staging`
- [ ] Pipeline triggers on push to `development`
- [ ] Pipeline triggers on pull requests to all three branches

### Quality Gates
- [ ] Quality gates run on all branches
- [ ] Linting/code checks execute
- [ ] Tests run successfully
- [ ] Build completes without errors

### Deployment Logic
- [ ] `development` branch deploys to staging
- [ ] `staging` branch deploys to staging
- [ ] `main` branch deploys to production
- [ ] `main` branch does NOT deploy to staging
- [ ] `development` branch does NOT deploy to production
- [ ] `staging` branch does NOT deploy to production

### Environment Protection
- [ ] Staging environment exists in GitHub
- [ ] Production environment exists in GitHub
- [ ] Environment-specific secrets are configured
- [ ] Deployment approvals work (if configured)

### Branch Management (Node.js template only)
- [ ] After main push, development branch is updated
- [ ] After main push, staging branch is updated
- [ ] Merge commits include `[skip ci]` flag
- [ ] No infinite loops occur

### Job Dependencies
- [ ] Deployments depend on quality gates
- [ ] Jobs run in correct order
- [ ] Failed quality gates block deployments
- [ ] Job status is reported correctly

## Common Issues and Solutions

### Issue: "Branch not found" error

**Solution:**
```bash
# Ensure all branches exist
git branch -a

# Create missing branches
git checkout -b development
git push origin development

git checkout -b staging  
git push origin staging
```

### Issue: Permission denied when pushing

**Solution:**
1. Go to Settings → Actions → General
2. Set "Workflow permissions" to "Read and write permissions"
3. Enable "Allow GitHub Actions to create and approve pull requests"

### Issue: Environment not found

**Solution:**
1. Go to Settings → Environments
2. Click "New environment"
3. Create `staging` and `production` environments

### Issue: Tests failing on first run

**Solution:**
- Ensure all project dependencies are committed
- Run tests locally first: `npm test` or `pytest`
- Check that test scripts exist in package.json
- Verify test files are in the correct location

### Issue: Branch management creates infinite loop

**Solution:**
- Verify `[skip ci]` is in merge commit messages
- Check that branch-management job has `if: github.event_name == 'push'`
- Ensure job only runs on `main` branch

### Issue: Workflows not triggering

**Solution:**
1. Check workflow file is in `.github/workflows/` directory
2. Verify YAML syntax is valid: `yamllint .github/workflows/ci-cd.yml`
3. Check branch names match exactly (case-sensitive)
4. Ensure workflows are enabled in Settings → Actions

## Performance Testing

### Test Concurrent Pushes

```bash
# Terminal 1
git checkout development
echo "test1" >> file1.txt
git add . && git commit -m "Test 1"
git push &

# Terminal 2
git checkout staging
echo "test2" >> file2.txt
git add . && git commit -m "Test 2"
git push &

# Terminal 3
git checkout main
echo "test3" >> file3.txt
git add . && git commit -m "Test 3"
git push &
```

Expected: All workflows should run independently without conflicts.

### Test Pull Request Flow

```bash
git checkout -b feature/test-pr
echo "# Feature" >> feature.md
git add . && git commit -m "Add feature"
git push origin feature/test-pr

# Create PR via GitHub UI or gh CLI
gh pr create --base development --title "Test PR" --body "Testing PR workflow"
```

Expected: Quality gates should run, but no deployments should trigger.

## Automated Validation

The `validate-workflow.yml` runs automatically on every push and includes:

- Branch validation
- Quality check simulation
- Staging deployment tests
- Production deployment tests
- Deployment isolation tests
- Validation report generation

View results in Actions tab: `Validate CI/CD Pipeline` workflow.

## Test Results Documentation

### Test Run: [Date]

**Environment:**
- Repository: [name]
- Branches tested: main, staging, development
- Templates tested: Node.js / Python / Generic

**Results:**

| Test | Status | Notes |
|------|--------|-------|
| Local validation script | ✅ | All 34 tests passed |
| Development push | ✅ | Deployed to staging |
| Staging push | ✅ | Deployed to staging |
| Main push | ✅ | Deployed to production |
| Branch sync | ✅ | Development and staging updated |
| Pull request | ✅ | Quality gates ran only |

**Issues Found:** None

**Conclusion:** Pipeline templates are production-ready.

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Environment Protection Rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)

---

**Last Updated:** October 31, 2024
**Maintained By:** Ross Sivertsen
