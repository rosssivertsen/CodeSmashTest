# CI/CD Pipeline Templates

This directory contains CI/CD pipeline templates for different project types.

## Available Templates

### 1. **pipeline-nodejs-template.yml** (Original)
For Node.js/TypeScript projects with npm.

**Features:**
- Node.js setup and caching
- TypeScript compilation
- ESLint analysis  
- npm security audit
- Automated testing with coverage
- Staging and production deployments
- Branch management automation

**Best for:** React, Vue, Angular, Express.js projects

---

### 2. **pipeline-python-template.yml** (NEW)
For Python projects with pip/poetry.

**Features:**
- Python setup and dependency management
- Python syntax validation
- Flake8/Pylint linting (if configured)
- pytest with coverage (if configured)
- Documentation verification
- Staging and production deployments

**Best for:** Django, Flask, FastAPI, data science projects

---

### 3. **pipeline-generic-template.yml** (NEW)
For any project type - customize as needed.

**Features:**
- Generic quality checks placeholder
- Documentation verification
- Staging and production deployments
- Notification hooks

**Best for:** Go, Rust, Java, or mixed-language projects

---

## Usage

### For New Projects:

**1. Choose the appropriate template:**
```bash
# Python project
cp ~/dev/enterprise-templates/change-control/pipeline-python-template.yml .github/workflows/ci-cd.yml

# Node.js project  
cp ~/dev/enterprise-templates/change-control/pipeline-nodejs-template.yml .github/workflows/ci-cd.yml

# Generic project
cp ~/dev/enterprise-templates/change-control/pipeline-generic-template.yml .github/workflows/ci-cd.yml
```

**2. Customize the workflow:**
- Update environment variables (Python version, Node version, etc.)
- Add your specific deployment commands
- Configure quality checks for your project
- Set up environment secrets if needed

**3. Commit and push:**
```bash
git add .github/workflows/ci-cd.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

---

## Common Customizations

### Add Environment Secrets

In your GitHub repository:
1. Go to Settings → Secrets and variables → Actions
2. Add secrets like:
   - `DEPLOY_KEY`
   - `API_TOKEN`
   - `DATABASE_URL`

Use in workflow:
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

### Enable Branch Protection

1. Go to Settings → Branches
2. Add rule for `main`, `staging`, `development`
3. Require status checks to pass
4. Require pull request reviews

### Modify Quality Gates

**For Python projects:**
```yaml
- name: Run Black formatter check
  run: black --check .

- name: Run mypy type checking
  run: mypy .
```

**For Node.js projects:**
```yaml
- name: Run Prettier check
  run: npm run format:check

- name: Run type checking
  run: npm run type-check
```

---

## Branch Strategy

All templates follow this branch hierarchy:

```
main (Production) ← staging (UAT) ← development (Integration)
    ↑                    ↑                    ↑
hotfix/*            feature/*           bugfix/*
```

**Deployment Flow:**
- Push to `development` → Deploys to staging
- Push to `staging` → Deploys to staging
- Push to `main` → Deploys to production

---

## Troubleshooting

### Workflow Fails on First Run

**Common issues:**

1. **Missing dependencies file**
   - Python: Add `requirements.txt` or remove pip cache
   - Node.js: Run `npm install` locally first to create `package-lock.json`

2. **Permission errors**
   - Go to Settings → Actions → General
   - Set "Workflow permissions" to "Read and write permissions"

3. **Tests failing**
   - Make sure tests pass locally first
   - Check test configuration files are committed

4. **Branch not found**
   - Create `development` and `staging` branches:
     ```bash
     git checkout -b development
     git push origin development
     git checkout -b staging
     git push origin staging
     ```

### Branch Management Issues (FIXED)

**Previous issues with branch management:**
- Branch checkout would fail due to shallow clone (missing `fetch-depth: 0`)
- Remote branches weren't properly fetched before merge
- No error handling for missing branches
- Missing workflow permissions for pushing changes

**Fixes applied in pipeline-template.yml:**
- ✅ Added `fetch-depth: 0` to checkout full git history
- ✅ Added explicit git fetch before checkout
- ✅ Added branch existence checks before merge
- ✅ Added `permissions: contents: write` to branch-management job
- ✅ Added `[skip ci]` to merge commits to prevent infinite loops
- ✅ Only runs on push events (not pull requests)

**If branch management still fails:**
1. Ensure the `GITHUB_TOKEN` has write permissions
2. Verify branches exist: `git branch -r`
3. Check branch protection rules don't block the workflow
4. For protected branches, you may need to use a Personal Access Token instead of `GITHUB_TOKEN`

---

## Template Comparison

| Feature | Node.js | Python | Generic |
|---------|---------|--------|---------|
| Language Setup | ✅ Node.js | ✅ Python | ❌ Manual |
| Dependency Management | ✅ npm | ✅ pip | ❌ Manual |
| Linting | ✅ ESLint | ⚠️ Optional | ❌ Manual |
| Testing | ✅ Built-in | ⚠️ Optional | ❌ Manual |
| Build Step | ✅ TypeScript | ❌ N/A | ❌ Manual |
| Security Audit | ✅ npm audit | ❌ Manual | ❌ Manual |

**Legend:**
- ✅ Fully configured
- ⚠️ Conditional/optional
- ❌ Not included (add manually)

---

## Best Practices

1. **Always test locally first** before pushing
2. **Use environment-specific secrets** for staging vs production
3. **Keep workflows simple** - add complexity as needed
4. **Document custom steps** in comments
5. **Use branch protection** to enforce quality gates
6. **Monitor workflow runs** and fix failures promptly

---

## Need Help?

1. Check the main enterprise-templates README
2. Review GitHub Actions documentation
3. Look at the working example in FirstCLIProject
4. Test workflows with small changes first

---

**Last Updated:** November 2024
**Maintained By:** Ross Sivertsen
