# CodeSmash AWS Deployment Guide

## 🚀 Overview

This guide covers deploying Next.js apps to AWS using the **CodeSmash platform** with automated workflows.

## Prerequisites

- ✅ CodeSmash account (one-time payment)
- ✅ AWS account (12 months free tier)
- ✅ GitHub account (CodeSmash manages repos)

## Architecture

```
┌─────────────────┐
│   REST API      │  ← AWS Lambda + API Gateway + DynamoDB
└────────┬────────┘
         │
┌────────▼────────┐
│  Web Hosting    │  ← CloudFront CDN + S3
└────────┬────────┘
         │
┌────────▼────────┐
│   Next.js App   │  ← Server-Side Rendered via Lambda@Edge
└─────────────────┘
```

## 🎯 Deployment Order (Critical!)

### 1️⃣ Deploy REST API First

**Via CodeSmash UI:**
1. Navigate to **REST API** section
2. Click **Add New**
3. Name your API (e.g., `my-app-api`)
4. Click **Deploy**
5. Wait for deployment to complete

**Configure API Routes:**
```bash
# After deployment, go to API Builder
1. Click on your API
2. Go to "API Builder"
3. Add routes (e.g., "users", "posts")
4. Click "Add Routes" - auto-generates CRUD
5. Click "Redeploy" to activate
```

**Test Your API:**
```bash
# You'll get a URL like:
https://abc123.execute-api.us-east-1.amazonaws.com/api/users

# Test endpoints:
GET    /api/users          # Get all
GET    /api/users/1        # Get by ID
POST   /api/users          # Create
PUT    /api/users/1        # Update
DELETE /api/users/1        # Delete
```

---

### 2️⃣ Deploy Dynamic Web Hosting

**Via CodeSmash UI:**
1. Navigate to **Dynamic Web Hosting** section
2. Click **Add New**
3. **Select your REST API** from dropdown
4. Name your hosting (e.g., `my-app-hosting`)
5. Click **Deploy**
6. Wait for CloudFront distribution to deploy (~5-10 min)

**You'll get a CDN URL:**
```
https://d1a2b3c4d5e6f7.cloudfront.net
```

**Important:** Your API is now accessible via:
```
https://d1a2b3c4d5e6f7.cloudfront.net/api/users
```

---

### 3️⃣ Deploy Next.js App

**Via CodeSmash UI:**
1. Navigate to **Server-Side Next.js** section
2. Click **Add New**
3. **Select your Web Hosting** from dropdown
4. Name your app (e.g., `my-nextjs-app`)
5. Click **Deploy**
6. CodeSmash creates GitHub repo automatically
7. Wait for initial build

**⚠️ Critical Step After Every Deployment:**
```
Go to Web Hosting → Click "Restart Hosting"
```

---

## 🔄 Development Workflow

### Initial Setup

**1. Clone from CodeSmash:**
```bash
# Get Git URL from CodeSmash UI
# Click on your Next.js app → Git section → Copy URL

git clone <codesmash-git-url>
cd my-nextjs-app
npm install
```

**2. Run Locally:**
```bash
npm run dev
# Opens on http://localhost:3000
```

**3. Configure Environment:**
```bash
# Create .env.local for local development
echo "NEXT_PUBLIC_API_URL=https://d1a2b3c4d5e6f7.cloudfront.net" > .env.local
```

---

### Making Changes

**1. Local Development:**
```bash
# Make your changes
# Test locally: npm run dev

# Example: Adding a new image
cp new-image.jpg public/
# Update components to use it
```

**2. Commit & Push:**
```bash
git add .
git commit -m "feat: add new feature"
git push origin main
```

**3. Automatic Build:**
- CodeSmash detects push automatically
- Build starts in CodeSmash UI (spinner appears)
- Wait for build to complete

**4. Restart Hosting (REQUIRED):**
```bash
# In CodeSmash UI:
1. Go to Web Hosting section
2. Click on your hosting
3. Click "Restart Hosting"
4. Wait for restart to complete
```

**5. Verify Deployment:**
```bash
# Visit your CDN URL
https://d1a2b3c4d5e6f7.cloudfront.net
# Changes should be live
```

---

## 🛠️ Automated Scripts

### Quick Deploy Script

Create `scripts/codesmash-deploy.sh`:
```bash
#!/bin/bash
echo "🚀 CodeSmash Deployment"
echo ""
echo "✅ Making commit..."
git add .
git commit -m "${1:-Update deployment}"
git push origin main

echo ""
echo "⏳ Build starting in CodeSmash..."
echo "📋 Next Steps:"
echo "   1. Wait for build to complete in CodeSmash UI"
echo "   2. Restart hosting manually"
echo "   3. Verify at your CDN URL"
```

**Usage:**
```bash
chmod +x scripts/codesmash-deploy.sh
./scripts/codesmash-deploy.sh "feat: add new feature"
```

---

## 📁 Project Structure

```
my-nextjs-app/
├── pages/
│   ├── index.js              # Home page
│   ├── users/
│   │   ├── index.js          # Users list
│   │   └── [id].js           # User detail
│   └── api/                  # Optional (use REST API instead)
├── public/
│   ├── images/
│   └── food.jpg              # Static assets
├── components/
│   └── ...
├── styles/
│   └── ...
├── scripts/
│   └── codesmash-deploy.sh   # Deployment automation
├── .env.local                # Local environment vars
├── .gitignore
├── package.json
└── next.config.js
```

---

## 🔌 API Integration

### Connecting to Your REST API

**In your Next.js components:**

```javascript
// lib/api.js
const API_URL = process.env.NEXT_PUBLIC_API_URL || '';

export async function getUsers() {
  const res = await fetch(`${API_URL}/api/users`);
  return res.json();
}

export async function getUser(id) {
  const res = await fetch(`${API_URL}/api/users/${id}`);
  return res.json();
}

export async function createUser(data) {
  const res = await fetch(`${API_URL}/api/users`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
  return res.json();
}

export async function updateUser(id, data) {
  const res = await fetch(`${API_URL}/api/users/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
  return res.json();
}

export async function deleteUser(id) {
  const res = await fetch(`${API_URL}/api/users/${id}`, {
    method: 'DELETE'
  });
  return res.json();
}
```

**In your pages:**

```javascript
// pages/users/index.js
import { getUsers } from '../../lib/api';

export async function getServerSideProps() {
  const users = await getUsers();
  return { props: { users } };
}

export default function Users({ users }) {
  return (
    <div>
      <h1>Users</h1>
      {users.map(user => (
        <div key={user.id}>
          <h2>{user.name}</h2>
          <p>{user.info}</p>
        </div>
      ))}
    </div>
  );
}
```

---

## ⚙️ Configuration

### next.config.js

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['d1a2b3c4d5e6f7.cloudfront.net'],
  },
  // CodeSmash handles routing
  trailingSlash: true,
}

module.exports = nextConfig
```

### Environment Variables

**Local (.env.local):**
```bash
NEXT_PUBLIC_API_URL=https://d1a2b3c4d5e6f7.cloudfront.net
```

**Production (CodeSmash UI):**
- Set in CodeSmash app settings
- No need to commit .env files

---

## 🔍 Monitoring & Debugging

### Check Build Status

**In CodeSmash UI:**
1. Go to your Next.js app
2. Check "Build Status" section
3. View build logs for errors

### Check Hosting Status

**In CodeSmash UI:**
1. Go to Web Hosting
2. View "Status" indicator
3. Check CloudFront distribution

### Check API Status

**Test API endpoints:**
```bash
curl https://d1a2b3c4d5e6f7.cloudfront.net/api/users
```

### View AWS Services

**From CodeSmash UI:**
1. Go to your app
2. Scroll to "Services" section
3. Click on service links (S3, Lambda, CloudFront, etc.)
4. Opens AWS console directly

---

## ⚠️ Critical Reminders

1. ✅ **Always deploy REST API first**
2. ✅ **Connect Web Hosting to REST API**
3. ✅ **Connect Next.js app to Web Hosting**
4. ✅ **Restart hosting after every deployment**
5. ✅ **Wait for builds to complete before restarting**
6. ✅ **API accessible via CDN URL, not separate endpoint**

---

## 🚨 Troubleshooting

### Build Fails
```bash
1. Check build logs in CodeSmash UI
2. Verify package.json scripts are correct
3. Ensure all dependencies are listed
4. Test build locally: npm run build
```

### Changes Not Appearing
```bash
1. Verify build completed in CodeSmash
2. Did you restart hosting? (Required!)
3. Clear browser cache
4. Check CloudFront invalidation
```

### API Not Working
```bash
1. Verify API is deployed
2. Check API routes in API Builder
3. Did you redeploy API after adding routes?
4. Test API directly: curl {api-url}
```

### Static Files Missing
```bash
1. Ensure files are in /public directory
2. Check S3 bucket in AWS console
3. Verify hosting was restarted
4. Check file paths are correct
```

---

## 📚 Additional Features

### Custom Domain (Future)
- Configure in CodeSmash UI
- Point DNS to CloudFront
- SSL certificate auto-generated

### Authentication (Future)
- Google OAuth
- Apple Sign In
- Email/Password
- Configured via CodeSmash UI

---

## 💰 Cost Optimization

**AWS Free Tier (12 months):**
- Lambda: 1M requests/month
- CloudFront: 1TB data transfer/month
- S3: 5GB storage
- API Gateway: 1M requests/month
- DynamoDB: 25GB storage

**Serverless Benefits:**
- No charges when idle
- Pay per request
- Auto-scaling
- No server management

---

## 📞 Support

**CodeSmash Issues:**
- Check CodeSmash documentation
- Support through CodeSmash platform

**AWS Issues:**
- Access AWS console via CodeSmash
- Check AWS CloudWatch logs
- Review AWS service health dashboard

---

**Last Updated:** November 14, 2025  
**Version:** 2.0.0 (CodeSmash Platform)  
**Author:** Ross Sivertsen
