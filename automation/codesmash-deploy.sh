#!/bin/bash

# CodeSmash Automated Deployment Script
# Automates git workflow for CodeSmash platform deployments

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get commit message from argument or use default
COMMIT_MSG="${1:-Update deployment}"

echo -e "${BLUE}🚀 CodeSmash Automated Deployment${NC}"
echo ""

# Check for uncommitted changes
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  No changes detected${NC}"
    echo "Nothing to deploy"
    exit 0
fi

# Show what's being committed
echo -e "${BLUE}📋 Changes to be committed:${NC}"
git status --short
echo ""

# Confirm deployment
read -p "Deploy these changes? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Deployment cancelled${NC}"
    exit 1
fi

# Commit and push
echo -e "${GREEN}✅ Committing changes...${NC}"
git add .
git commit -m "$COMMIT_MSG"

echo -e "${GREEN}✅ Pushing to CodeSmash...${NC}"
git push origin main

echo ""
echo -e "${GREEN}🎉 Deployment initiated!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo -e "   1. ⏳ Wait for build to complete in CodeSmash UI"
echo -e "   2. 🔄 Go to Web Hosting → Click 'Restart Hosting'"
echo -e "   3. ✅ Verify changes at your CDN URL"
echo ""
echo -e "${YELLOW}⚠️  Remember: Hosting restart is REQUIRED for changes to appear${NC}"
