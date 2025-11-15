# How to Use Enterprise Templates Repository

## Overview

This repository serves as a **template library** that you can clone or pull from to start new projects or update existing ones with production-tested CI/CD pipelines.

## Two Ways to Use This Repository

### Method 1: Clone for New Projects (Recommended)

Use this method when starting a brand new project.

```bash
# 1. Clone the enterprise templates repository
git clone https://github.com/YOUR_USERNAME/enterprise-templates.git
cd enterprise-templates

# 2. Choose your template and copy to new project
mkdir ~/projects/my-new-project
cp change-control/pipeline-template.yml ~/projects/my-new-project/.github/workflows/ci-cd.yml

# 3. Set up your new project
cd ~/projects/my-new-project
git init
git add .
git commit -m "Initial commit with CI/CD pipeline"
```

**Benefits:**
- Always get the latest tested version
- Easy to update templates in the future
- Can diff changes between versions
- Version controlled template library

### Method 2: Keep Local Copy

Use this method if you prefer working with a local copy.

```bash
# 1. Keep templates in a central location
ls ~/dev/enterprise-templates/

# 2. Copy templates when needed
cp ~/dev/enterprise-templates/change-control/pipeline-template.yml \
   ~/projects/new-project/.github/workflows/ci-cd.yml

# 3. Update local copy periodically
cd ~/dev/enterprise-templates
git pull origin main
```

**Benefits:**
- Works offline
- Faster access
- Can customize templates locally

## Creating a New Project

### Step-by-Step Process

#### 1. Clone or Update Templates

**If first time:**
```bash
git clone https://github.com/YOUR_USERNAME/enterprise-templates.git ~/dev/enterprise-templates
```

**If already cloned:**
```bash
cd ~/dev/enterprise-templates
git pull origin main
```

#### 2. Create Your New Project

```bash
# Create project directory
mkdir ~/projects/my-new-project
cd ~/projects/my-new-project

# Initialize git
git init
git branch -M main
```

#### 3. Copy Appropriate Template

**For Node.js/TypeScript:**
```bash
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-template.yml \
   .github/workflows/ci-cd.yml
```

**For Python:**
```bash
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-python-template.yml \
   .github/workflows/ci-cd.yml
```

**For Generic:**
```bash
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-generic-template.yml \
   .github/workflows/ci-cd.yml
```

#### 4. Customize the Workflow

Edit `.github/workflows/ci-cd.yml` to add your deployment commands:

```yaml
- name: Deploy to staging
  run: |
    # Replace with your deployment commands
    npm run deploy:staging
    # or
    ./deploy.sh staging
```

#### 5. Set Up Branches

```bash
# Create development branch
git checkout -b development
git add .
git commit -m "Initial setup with CI/CD pipeline"
git push -u origin development

# Create staging branch
git checkout -b staging
git push -u origin staging

# Push main
git checkout main
git push -u origin main
```

#### 6. Configure GitHub

1. Go to repository Settings → Environments
2. Create two environments:
   - `staging`
   - `production`
3. Add any required secrets

#### 7. Test the Pipeline

```bash
# Make a change and push
echo "# My Project" > README.md
git add README.md
git commit -m "Add README"
git push origin development
```

Check the Actions tab to see the pipeline run!

## Updating Existing Projects

### Pulling Template Updates

```bash
# 1. Update your local templates
cd ~/dev/enterprise-templates
git pull origin main

# 2. Check what changed
git log --oneline v1.0.0..HEAD -- change-control/pipeline-template.yml

# 3. See the diff
git diff v1.0.0 HEAD -- change-control/pipeline-template.yml

# 4. Copy updated template to your project (backup first!)
cp ~/projects/my-project/.github/workflows/ci-cd.yml \
   ~/projects/my-project/.github/workflows/ci-cd.yml.backup

cp ~/dev/enterprise-templates/change-control/pipeline-template.yml \
   ~/projects/my-project/.github/workflows/ci-cd.yml

# 5. Review and merge your customizations
diff ~/projects/my-project/.github/workflows/ci-cd.yml.backup \
     ~/projects/my-project/.github/workflows/ci-cd.yml
```

## Version Management

### Using Specific Versions

```bash
# List available versions
cd ~/dev/enterprise-templates
git tag -l

# Checkout specific version
git checkout v1.0.0

# Copy template from that version
cp change-control/pipeline-template.yml ~/projects/my-project/.github/workflows/

# Return to latest
git checkout main
```

### Creating a Project with Specific Version

```bash
# Clone specific version directly
git clone --branch v1.0.0 https://github.com/YOUR_USERNAME/enterprise-templates.git \
  enterprise-templates-v1.0.0

# Copy template
cp enterprise-templates-v1.0.0/change-control/pipeline-template.yml \
   my-project/.github/workflows/ci-cd.yml
```

## Common Workflows

### Scenario 1: Starting a React Project

```bash
# 1. Update templates
cd ~/dev/enterprise-templates && git pull origin main

# 2. Create project
npx create-react-app my-react-app
cd my-react-app

# 3. Add CI/CD pipeline
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-template.yml \
   .github/workflows/ci-cd.yml

# 4. Set up branches
git checkout -b development && git push -u origin development
git checkout -b staging && git push -u origin staging
git checkout main && git push -u origin main

# 5. Configure GitHub environments
# Go to Settings → Environments → Create "staging" and "production"
```

### Scenario 2: Starting a Python/Django Project

```bash
# 1. Update templates
cd ~/dev/enterprise-templates && git pull origin main

# 2. Create project
django-admin startproject myproject
cd myproject

# 3. Add CI/CD pipeline
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-python-template.yml \
   .github/workflows/ci-cd.yml

# 4. Set up git
git init
git add .
git commit -m "Initial commit"

# 5. Set up branches (same as above)
```

### Scenario 3: Adding CI/CD to Existing Project

```bash
# 1. Navigate to your project
cd ~/projects/existing-project

# 2. Update templates
cd ~/dev/enterprise-templates && git pull origin main
cd ~/projects/existing-project

# 3. Add pipeline
mkdir -p .github/workflows
cp ~/dev/enterprise-templates/change-control/pipeline-template.yml \
   .github/workflows/ci-cd.yml

# 4. Create additional branches if needed
git checkout -b development
git push -u origin development
git checkout -b staging
git push -u origin staging

# 5. Commit and push
git checkout main
git add .github/workflows/ci-cd.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

## Testing Before Production

### Validate Template Locally

```bash
# Run validation tests
cd ~/dev/enterprise-templates/test-project
./test-pipelines.sh

# Test branch management
./test-branch-management.sh
```

### Validate in Test Repository

```bash
# Create test repository
mkdir ~/projects/test-pipeline
cd ~/projects/test-pipeline
git init

# Copy validation workflow
cp ~/dev/enterprise-templates/test-project/.github/workflows/validate-workflow.yml \
   .github/workflows/

# Push and check Actions tab
git add .
git commit -m "Test pipeline"
git push origin main
```

## Maintenance

### Keeping Your Template Library Updated

```bash
# Weekly or monthly update
cd ~/dev/enterprise-templates
git pull origin main

# Check for new versions
git tag -l

# Review release notes
git log --oneline --decorate
```

### When to Update Your Projects

**Update immediately:**
- Security vulnerabilities fixed
- Critical bugs patched

**Review before updating:**
- Major version changes (2.0.0)
- Breaking changes in release notes
- New requirements or dependencies

**Schedule regular updates:**
- Minor versions (1.1.0, 1.2.0)
- Documentation improvements
- New features you want to use

## Best Practices

### 1. Always Keep Templates Updated
```bash
# Set a reminder to update monthly
cd ~/dev/enterprise-templates && git pull origin main
```

### 2. Test Updates Before Deploying
```bash
# Copy to test project first
cp template.yml test-project/.github/workflows/
# Test in test project
# Then deploy to production projects
```

### 3. Backup Before Updating
```bash
# Always backup your current workflow
cp .github/workflows/ci-cd.yml .github/workflows/ci-cd.yml.backup
```

### 4. Document Your Customizations
```yaml
# Add comments to your customizations
- name: Deploy to staging
  run: |
    # CUSTOM: Added specific deployment command for our infrastructure
    ./custom-deploy.sh staging
```

### 5. Use Version Tags for Production
```bash
# Pin to specific version for critical projects
git checkout v1.0.0
cp change-control/pipeline-template.yml critical-project/.github/workflows/
```

## Troubleshooting

### Templates Not Found

```bash
# Verify repository location
ls ~/dev/enterprise-templates/change-control/

# If not found, clone again
git clone https://github.com/YOUR_USERNAME/enterprise-templates.git \
  ~/dev/enterprise-templates
```

### Workflow Not Triggering

```bash
# Check file is in correct location
ls .github/workflows/ci-cd.yml

# Check YAML syntax
yamllint .github/workflows/ci-cd.yml

# Check branches match
git branch -a
```

### Updates Breaking Your Project

```bash
# Restore backup
cp .github/workflows/ci-cd.yml.backup .github/workflows/ci-cd.yml

# Or checkout previous commit
git log -- .github/workflows/ci-cd.yml
git checkout <commit-hash> -- .github/workflows/ci-cd.yml
```

## Support & Documentation

### Available Documentation

- **QUICK-START.md** - 5-minute setup guide
- **TESTING-GUIDE.md** - Comprehensive testing documentation
- **TEST-RESULTS.md** - Detailed test results
- **TESTING-SUMMARY.md** - Executive summary
- **change-control/README.md** - Template-specific docs

### Getting Help

1. Check test-project/TESTING-GUIDE.md
2. Run validation tests locally
3. Review test-project/TEST-RESULTS.md
4. Check GitHub Actions logs
5. Review template comments

---

## Summary: Quick Reference

### New Project
```bash
git clone https://github.com/YOUR_USERNAME/enterprise-templates.git
cp enterprise-templates/change-control/pipeline-template.yml my-project/.github/workflows/ci-cd.yml
```

### Update Templates
```bash
cd ~/dev/enterprise-templates && git pull origin main
```

### Specific Version
```bash
cd ~/dev/enterprise-templates
git checkout v1.0.0
cp change-control/pipeline-template.yml my-project/.github/workflows/
git checkout main
```

### Test Before Deploy
```bash
cd ~/dev/enterprise-templates/test-project
./test-pipelines.sh
```

---

**Last Updated:** October 31, 2024  
**Version:** 1.0.0  
**Maintained By:** Ross Sivertsen
