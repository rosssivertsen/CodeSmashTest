# CodeSmash Quick Reference

## 🚀 One-Page Cheat Sheet

### Setup (One Time Only)

```bash
# 1. In CodeSmash UI (in this order!):
   REST API → Deploy → Add Routes → Redeploy
   Web Hosting → Select API → Deploy
   Next.js App → Select Hosting → Deploy

# 2. Clone & Setup Locally:
   git clone <codesmash-git-url>
   cd project
   npm install
   cp .env.local.template .env.local
   # Edit .env.local with your CDN URL
```

### Daily Development

```bash
# Local Development
npm run dev                           # Test at localhost:3000

# Deploy to CodeSmash
./scripts/deploy.sh "feat: message"   # Auto commit + push

# In CodeSmash UI:
1. Wait for build ⏳
2. Restart Hosting ⚠️ REQUIRED
3. Verify at CDN URL ✅
```

### Common Commands

```bash
# Development
npm run dev          # Start dev server
npm run build        # Test production build
npm run lint         # Check code quality

# Deployment
git status           # Check changes
git add .            # Stage changes
git commit -m "msg"  # Commit
git push            # Deploy
```

### Environment URLs

```bash
# Local
http://localhost:3000

# Production (CodeSmash)
https://d1a2b3c4d5e6f7.cloudfront.net

# API Endpoints (via CDN)
https://d1a2b3c4d5e6f7.cloudfront.net/api/users
```

### API Integration

```javascript
// Get all users
const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/users`);
const users = await res.json();

// Get one user
const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/users/1`);
const user = await res.json();

// Create user
const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/users`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'John', info: 'Developer' })
});

// Update user
const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/users/1`, {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'Jane', info: 'Designer' })
});

// Delete user
const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/users/1`, {
  method: 'DELETE'
});
```

### Critical Reminders ⚠️

1. **Deployment Order**: API → Hosting → Next.js
2. **Always Restart Hosting** after builds
3. **API via CDN URL** not separate endpoint
4. **Test Locally First** before deploying
5. **Wait for Build** before restarting

### Troubleshooting

| Problem | Solution |
|---------|----------|
| Changes not showing | Restart hosting (required!) |
| Build fails | Check CodeSmash logs, test `npm run build` locally |
| API not working | Verify deployed, check routes, test with curl |
| 404 errors | Clear cache, check file paths, verify hosting restarted |

### File Structure

```
project/
├── pages/           # Next.js pages
│   ├── index.js
│   ├── users/
│   └── api/        # (use REST API instead)
├── public/         # Static assets
├── components/     # React components
├── lib/            # Utilities (API helpers)
├── scripts/
│   └── deploy.sh   # Quick deploy
├── .env.local      # Local environment
└── next.config.js  # Config
```

### AWS Services Used

- **Lambda**: Serverless compute
- **API Gateway**: REST API endpoints
- **DynamoDB**: NoSQL database
- **CloudFront**: Global CDN
- **S3**: Static file storage
- **Lambda@Edge**: SSR Next.js

### Cost

**Free Tier (12 months):**
- 1M Lambda requests/month
- 1TB CloudFront data/month
- 5GB S3 storage
- 1M API Gateway requests/month

**After Free Tier:** Pay per use, $0 when idle

---

## 📚 Full Documentation

- **[CODESMASH-DEPLOYMENT.md](./CODESMASH-DEPLOYMENT.md)** - Complete guide
- **[README-CODESMASH.md](./README-CODESMASH.md)** - Framework overview
- **test-react-app/** - Working example

---

**Questions?** Check full docs or CodeSmash support

**Version:** 2.0.0 | **Author:** Ross Sivertsen
