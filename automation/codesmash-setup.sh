#!/bin/bash

# CodeSmash Quick Setup Script
# Sets up a new project for CodeSmash deployment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 CodeSmash Project Setup${NC}"
echo ""

# Get project information
read -p "CodeSmash Git URL: " GIT_URL
read -p "Project Name: " PROJECT_NAME

# Clone from CodeSmash
echo -e "${BLUE}📥 Cloning from CodeSmash...${NC}"
git clone "$GIT_URL" "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install

# Create scripts directory
echo -e "${BLUE}📁 Creating automation scripts...${NC}"
mkdir -p scripts

# Copy deploy script
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
# Quick deploy to CodeSmash
COMMIT_MSG="${1:-Update deployment}"
git add .
git commit -m "$COMMIT_MSG" || true
git push origin main
echo ""
echo "⏳ Build starting in CodeSmash..."
echo "📋 Don't forget to restart hosting!"
EOF

chmod +x scripts/deploy.sh

# Create env template
echo -e "${BLUE}⚙️  Creating environment template...${NC}"
cat > .env.local.template << 'EOF'
# Local Development Environment Variables
# Copy this to .env.local and fill in your values

# CodeSmash CDN URL
NEXT_PUBLIC_API_URL=https://your-cdn-url.cloudfront.net

# Add other environment variables as needed
EOF

# Add to gitignore
if ! grep -q ".env.local" .gitignore 2>/dev/null; then
    echo ".env.local" >> .gitignore
fi

# Create README section
cat >> README.md << 'EOF'

## 🚀 CodeSmash Deployment

### Quick Deploy
```bash
./scripts/deploy.sh "your commit message"
```

### Setup
1. Copy `.env.local.template` to `.env.local`
2. Fill in your CodeSmash CDN URL
3. Run `npm run dev` to start local development

### Deployment Steps
1. Make your changes
2. Test locally: `npm run dev`
3. Deploy: `./scripts/deploy.sh "feat: add new feature"`
4. Wait for build in CodeSmash UI
5. **Restart hosting** (critical!)
6. Verify at your CDN URL
EOF

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. cd $PROJECT_NAME"
echo "2. cp .env.local.template .env.local"
echo "3. Edit .env.local with your CodeSmash CDN URL"
echo "4. npm run dev"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"
