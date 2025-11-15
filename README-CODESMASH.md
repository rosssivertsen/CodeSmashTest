# CodeSmash Project Framework

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Status](https://img.shields.io/badge/status-production--ready-success.svg)

## 🎯 Overview

Complete framework for deploying applications using **CodeSmash platform** on AWS with full automation.

**What is CodeSmash?**
- Platform that deploys to YOUR private AWS account
- One-time payment (no monthly subscriptions)
- Serverless architecture (pay-as-you-go, free when idle)
- 12 months AWS free tier
- No vendor lock-in (your data stays in your AWS)

## 📁 Repository Structure

```
CodeSmashTestProject/
├── automation/
│   ├── codesmash-deploy.sh       # Automated git deployment
│   ├── codesmash-setup.sh        # New project setup
│   ├── configure-project.sh      # Project configuration
│   └── deploy-template.sh        # General deployment
├── change-control/
│   ├── pipeline-template.yml     # GitHub Actions (optional)
│   ├── pipeline-python-template.yml
│   └── pipeline-generic-template.yml
├── test-react-app/               # Test project example
├── CODESMASH-DEPLOYMENT.md       # Complete deployment guide
├── USAGE.md                      # Template usage guide
└── README.md                     # This file
```

## 🚀 Quick Start - New Project

### Option 1: CodeSmash Platform (Recommended for AWS)

```bash
# 1. Create REST API in CodeSmash UI first
# 2. Create Dynamic Web Hosting (link to API)
# 3. Create Next.js app (link to hosting)
# 4. Get Git URL from CodeSmash

# 5. Setup locally
./automation/codesmash-setup.sh
# Follow prompts to clone and configure

# 6. Start developing
cd your-project
npm run dev
```

### Option 2: Self-Hosted with GitHub Actions

```bash
# Use traditional CI/CD approach
cp change-control/pipeline-template.yml your-project/.github/workflows/ci-cd.yml
```

## 📚 Documentation

### CodeSmash Platform Deployment
- **[CODESMASH-DEPLOYMENT.md](./CODESMASH-DEPLOYMENT.md)** - Complete AWS deployment guide
  - REST API setup
  - Web hosting configuration  
  - Next.js deployment
  - Development workflow
  - API integration examples

### Traditional CI/CD
- **[USAGE.md](./USAGE.md)** - GitHub Actions templates
- **change-control/README.md** - Pipeline documentation

## 🔄 Development Workflow

### CodeSmash Platform Workflow

```bash
# 1. Make changes locally
npm run dev  # Test locally

# 2. Deploy to CodeSmash
./scripts/deploy.sh "feat: add new feature"

# 3. In CodeSmash UI:
#    - Wait for build to complete
#    - Go to Web Hosting → Restart Hosting ⚠️ CRITICAL
#    - Verify at CDN URL
```

### Key Points
- ✅ CodeSmash watches your GitHub repo
- ✅ Builds start automatically on push
- ✅ **Must restart hosting** after build completes
- ✅ Changes appear on CloudFront CDN

## 🏗️ CodeSmash Architecture

```
┌─────────────────┐
│   REST API      │  ← Lambda + API Gateway + DynamoDB
│  (Deploy First) │     Generates CRUD routes automatically
└────────┬────────┘
         │
┌────────▼────────┐
│  Web Hosting    │  ← CloudFront CDN + S3
│  (Deploy Second)│     Links to REST API
└────────┬────────┘     API available at /api/*
         │
┌────────▼────────┐
│   Next.js App   │  ← Server-Side Rendered
│  (Deploy Third) │     Links to Web Hosting
└─────────────────┘     Automatic GitHub integration
```

## 🛠️ Automation Scripts

### codesmash-deploy.sh
Automates git workflow for CodeSmash deployments:
```bash
./automation/codesmash-deploy.sh "your commit message"
```
- Shows changes to be committed
- Confirms before deploying
- Pushes to CodeSmash
- Reminds to restart hosting

### codesmash-setup.sh
Sets up a new project from CodeSmash:
```bash
./automation/codesmash-setup.sh
```
- Clones from CodeSmash Git URL
- Installs dependencies
- Creates deployment scripts
- Generates environment templates
- Updates README with instructions

## 📋 Deployment Checklist

### Initial Setup (One Time)

- [ ] Create AWS account (if needed)
- [ ] Create CodeSmash account
- [ ] Deploy REST API in CodeSmash UI
- [ ] Deploy Web Hosting (link to API)
- [ ] Deploy Next.js app (link to hosting)
- [ ] Clone repo locally
- [ ] Run `npm install`
- [ ] Configure `.env.local`

### Every Deployment

- [ ] Make changes locally
- [ ] Test: `npm run dev`
- [ ] Deploy: `./scripts/deploy.sh "message"`
- [ ] Wait for build in CodeSmash UI
- [ ] **Restart hosting** ⚠️
- [ ] Verify at CDN URL

## ⚙️ Configuration

### Environment Variables

**Local Development (.env.local):**
```bash
NEXT_PUBLIC_API_URL=https://your-cdn-url.cloudfront.net
```

**Production (CodeSmash UI):**
- Set in app settings
- No need to commit

### Next.js Config

```javascript
// next.config.js
module.exports = {
  reactStrictMode: true,
  images: {
    domains: ['your-cdn-url.cloudfront.net'],
  },
  trailingSlash: true,
}
```

## 🔌 API Integration Example

```javascript
// lib/api.js
const API_URL = process.env.NEXT_PUBLIC_API_URL || '';

export async function getUsers() {
  const res = await fetch(`${API_URL}/api/users`);
  return res.json();
}

// pages/users/index.js
import { getUsers } from '../../lib/api';

export async function getServerSideProps() {
  const users = await getUsers();
  return { props: { users } };
}

export default function Users({ users }) {
  return (
    <div>
      {users.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  );
}
```

## ⚠️ Critical Reminders

1. **Deployment Order Matters:**
   - Deploy REST API → Web Hosting → Next.js App

2. **Always Restart Hosting:**
   - Required after every deployment
   - Changes won't appear without it

3. **API Integration:**
   - Use CDN URL, not separate API endpoint
   - API accessible at: `{cdn-url}/api/*`

4. **Static Assets:**
   - Store in `/public` directory
   - Automatically copied to S3

5. **Build Verification:**
   - Test locally before pushing
   - Check build logs in CodeSmash UI

## 🧪 Test Project

See `test-react-app/` for a complete working example:
- React + TypeScript + Vite
- Deployment scripts included
- Three-tier branch strategy
- Quality gates and automation

## 💰 Cost Optimization

**AWS Free Tier (12 months):**
- Lambda: 1M requests/month free
- CloudFront: 1TB data transfer/month free
- S3: 5GB storage free
- API Gateway: 1M requests/month free
- DynamoDB: 25GB storage free

**Serverless = $0 when idle**

## 🚨 Troubleshooting

### Changes Not Appearing
```bash
1. Check build completed in CodeSmash UI
2. Did you restart hosting? ⚠️
3. Clear browser cache
4. Check CloudFront invalidation
```

### Build Fails
```bash
1. Check build logs in CodeSmash
2. Test locally: npm run build
3. Verify package.json scripts
4. Check dependencies
```

### API Not Working
```bash
1. Verify API is deployed
2. Check routes in API Builder
3. Redeploy API after route changes
4. Test directly: curl {api-url}
```

## 📞 Support

**Documentation:**
- [CODESMASH-DEPLOYMENT.md](./CODESMASH-DEPLOYMENT.md) - Complete guide
- [USAGE.md](./USAGE.md) - Template usage
- test-project/ - Testing documentation

**CodeSmash Platform:**
- Check CodeSmash documentation
- Support through platform

**AWS Console:**
- Access via CodeSmash UI
- View CloudWatch logs
- Check service health

## 📝 Version History

**v2.0.0** (November 2025)
- Added CodeSmash platform integration
- Automated deployment scripts
- Complete AWS deployment guide
- API integration examples

**v1.0.0** (October 2024)
- GitHub Actions CI/CD templates
- Three-tier branch strategy
- Quality gates automation
- 44/44 tests passing

## 👤 Author

Ross Sivertsen

## 📄 License

MIT

---

**Choose Your Deployment Strategy:**
- 🚀 **CodeSmash Platform** → AWS serverless, automated, pay-as-you-go
- 🔧 **GitHub Actions** → Self-hosted, full control, traditional CI/CD

Both approaches work with the same codebase!
