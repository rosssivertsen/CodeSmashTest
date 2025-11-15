# Quick Start Guide - CI/CD Pipeline Templates

## TL;DR

```bash
# 1. Copy the appropriate template
cp ~/dev/enterprise-templates/change-control/pipeline-template.yml .github/workflows/ci-cd.yml

# 2. Create branches
git checkout -b development && git push origin development
git checkout -b staging && git push origin staging

# 3. Set up GitHub environments
# Go to: Settings → Environments → New environment
# Create: "staging" and "production"

# 4. Push and deploy!
git checkout main && git push origin main
```

## Choose Your Template

### Node.js/TypeScript Projects
```bash
cp ~/dev/enterprise-templates/change-control/pipeline-template.yml .github/workflows/ci-cd.yml
```
**Best for:** React, Vue, Angular, Express, Next.js

### Python Projects
```bash
cp ~/dev/enterprise-templates/change-control/pipeline-python-template.yml .github/workflows/ci-cd.yml
```
**Best for:** Django, Flask, FastAPI, data science

### Generic Projects
```bash
cp ~/dev/enterprise-templates/change-control/pipeline-generic-template.yml .github/workflows/ci-cd.yml
```
**Best for:** Go, Rust, Java, multi-language

## Branch Setup

```bash
# Start from main
git checkout main

# Create and push development
git checkout -b development
git push -u origin development

# Create and push staging
git checkout -b staging
git push -u origin staging

# Back to main
git checkout main
```

## GitHub Configuration

### 1. Create Environments
**Settings → Environments → New environment**

Create two environments:
- `staging`
- `production`

### 2. Add Secrets (if needed)
**Settings → Secrets and variables → Actions → New repository secret**

Examples:
- `DEPLOY_KEY`
- `API_TOKEN`
- `DATABASE_URL`

### 3. Enable Actions
**Settings → Actions → General**
- ✅ Allow all actions and reusable workflows
- ✅ Read and write permissions
- ✅ Allow GitHub Actions to create and approve pull requests

### 4. Set Up Branch Protection (Optional)
**Settings → Branches → Add rule**

For `main`:
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Include administrators

## Deployment Flow

```
Feature branch → development → staging → main
     |               |            |        |
     |               ↓            ↓        ↓
   PR Review    Deploy to    Deploy to  Deploy to
                 Staging      Staging   Production
```

### Push to Development
```bash
git checkout development
git add .
git commit -m "Add new feature"
git push origin development
```
**Result:** Deploys to staging environment

### Push to Staging
```bash
git checkout staging
git add .
git commit -m "Ready for UAT"
git push origin staging
```
**Result:** Deploys to staging environment

### Push to Main
```bash
git checkout main
git add .
git commit -m "Release v1.0.0"
git push origin main
```
**Result:** Deploys to production environment

## Customization

### Update Deployment Commands

Edit your `.github/workflows/ci-cd.yml`:

```yaml
- name: Deploy to staging
  run: |
    # Replace this with your deployment commands
    npm run deploy:staging
    # or
    ./deploy-script.sh staging
```

### Change Node/Python Version

```yaml
env:
  NODE_VERSION: '20'  # Change from 18 to 20
  # or
  PYTHON_VERSION: '3.11'  # Change from 3.12 to 3.11
```

### Add Notification

```yaml
- name: Notify deployment
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
      -d "Deployed to production!"
```

## Testing Your Setup

### Run Validation Tests
```bash
cd ~/dev/enterprise-templates/test-project
./test-pipelines.sh
```
**Expected:** All 34 tests pass

### Test in Your Repo
```bash
# Copy validation workflow
cp ~/dev/enterprise-templates/test-project/.github/workflows/validate-workflow.yml .github/workflows/

# Push to trigger
git add .github/workflows/validate-workflow.yml
git commit -m "Add validation workflow"
git push
```

Check Actions tab for results.

## Troubleshooting

### Workflows Not Running?
```bash
# Check workflow file location
ls -la .github/workflows/

# Verify YAML syntax
yamllint .github/workflows/ci-cd.yml
```

### Permission Errors?
**Settings → Actions → General**
- Set to "Read and write permissions"

### Environment Not Found?
**Settings → Environments**
- Create `staging` and `production` environments

### Tests Failing?
```bash
# Run locally first
npm test  # or pytest, or your test command
npm run build  # verify build works
```

### Branch Not Deploying?
```bash
# Check branch name exactly matches
git branch -a

# Ensure you're pushing to correct branch
git push origin development  # not develop!
```

## Common Workflows

### Feature Development
```bash
# Create feature branch from development
git checkout development
git pull origin development
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "Add my feature"

# Push and create PR
git push origin feature/my-feature
gh pr create --base development
```

### Hotfix Production
```bash
# Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/fix-critical-bug

# Fix and commit
git add .
git commit -m "Fix critical bug"

# Merge to main
git checkout main
git merge hotfix/fix-critical-bug
git push origin main

# Automatic: main syncs to staging and development (Node.js template)
```

### Release Workflow
```bash
# 1. Develop features in development
git checkout development
# ... work ...
git push origin development

# 2. Test in staging
git checkout staging
git merge development
git push origin staging

# 3. Release to production
git checkout main
git merge staging
git push origin main
```

## Monitoring

### Check Workflow Status
```bash
# Via CLI
gh run list

# Via Web
https://github.com/YOUR_USERNAME/YOUR_REPO/actions
```

### View Deployment History
```bash
gh run list --workflow=ci-cd.yml --limit 10
```

### Check Branch Status
```bash
git branch -vv
```

## Help

### Documentation
- Full guide: `test-project/TESTING-GUIDE.md`
- Test results: `test-project/TEST-RESULTS.md`
- Template docs: `change-control/README.md`

### Test Scripts
- `test-project/test-pipelines.sh` - Validate templates
- `test-project/test-branch-management.sh` - Test automation

### GitHub Resources
- [Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

**Ready to deploy?** Copy your template and follow the steps above!
