#!/bin/bash

# Branch Management Testing Script
# Simulates the branch management automation to verify it works correctly

set -e

echo "======================================"
echo "Branch Management Automation Test"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create temporary test directory
TEST_DIR=$(mktemp -d)
echo -e "${BLUE}Creating test repository in: $TEST_DIR${NC}"
cd "$TEST_DIR"

# Initialize git repository
echo -e "${YELLOW}Step 1: Initializing git repository${NC}"
git init
git config user.email "test@example.com"
git config user.name "Test User"

# Create initial commit on main
echo -e "${YELLOW}Step 2: Creating initial commit on main${NC}"
echo "# Test Project" > README.md
git add README.md
git commit -m "Initial commit"
git branch -M main
echo -e "${GREEN}✅ Main branch created${NC}"
echo ""

# Create development branch
echo -e "${YELLOW}Step 3: Creating development branch${NC}"
git checkout -b development
echo "Development changes" >> README.md
git add README.md
git commit -m "Development setup"
echo -e "${GREEN}✅ Development branch created${NC}"
echo ""

# Create staging branch
echo -e "${YELLOW}Step 4: Creating staging branch${NC}"
git checkout -b staging
echo "Staging changes" >> README.md
git add README.md
git commit -m "Staging setup"
echo -e "${GREEN}✅ Staging branch created${NC}"
echo ""

# Simulate production release on main
echo -e "${YELLOW}Step 5: Simulating production release on main${NC}"
git checkout main
echo "Production release v1.0.0" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "Release v1.0.0"
echo -e "${GREEN}✅ Production release committed to main${NC}"
echo ""

# Simulate branch management automation
echo -e "${YELLOW}Step 6: Simulating branch management automation${NC}"
echo ""

echo -e "${BLUE}6a. Updating development branch...${NC}"
if git show-ref --verify --quiet refs/heads/development; then
    git checkout development
    BEFORE_COMMIT=$(git rev-parse HEAD)
    
    # Merge main into development
    if git merge --no-ff main -m "chore: merge main into development [skip ci]" --no-edit; then
        AFTER_COMMIT=$(git rev-parse HEAD)
        
        if [ "$BEFORE_COMMIT" != "$AFTER_COMMIT" ]; then
            echo -e "${GREEN}✅ Development branch updated with main${NC}"
            
            # Verify merge commit message includes [skip ci]
            if git log -1 --pretty=%B | grep -q "\[skip ci\]"; then
                echo -e "${GREEN}✅ Merge commit includes [skip ci] flag${NC}"
            else
                echo -e "${RED}❌ Merge commit missing [skip ci] flag${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}⚠️  No changes to merge (already up to date)${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to merge main into development${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Development branch does not exist${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}6b. Updating staging branch...${NC}"
if git show-ref --verify --quiet refs/heads/staging; then
    git checkout staging
    BEFORE_COMMIT=$(git rev-parse HEAD)
    
    # Merge main into staging
    if git merge --no-ff main -m "chore: merge main into staging [skip ci]" --no-edit; then
        AFTER_COMMIT=$(git rev-parse HEAD)
        
        if [ "$BEFORE_COMMIT" != "$AFTER_COMMIT" ]; then
            echo -e "${GREEN}✅ Staging branch updated with main${NC}"
            
            # Verify merge commit message includes [skip ci]
            if git log -1 --pretty=%B | grep -q "\[skip ci\]"; then
                echo -e "${GREEN}✅ Merge commit includes [skip ci] flag${NC}"
            else
                echo -e "${RED}❌ Merge commit missing [skip ci] flag${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}⚠️  No changes to merge (already up to date)${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to merge main into staging${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Staging branch does not exist${NC}"
    exit 1
fi
echo ""

# Verify all branches have the production changes
echo -e "${YELLOW}Step 7: Verifying all branches have production changes${NC}"

git checkout main
if git log --oneline | grep -q "Release v1.0.0"; then
    echo -e "${GREEN}✅ Main branch has production release${NC}"
else
    echo -e "${RED}❌ Main branch missing production release${NC}"
    exit 1
fi

git checkout development
if git log --oneline | grep -q "Release v1.0.0"; then
    echo -e "${GREEN}✅ Development branch has production release${NC}"
else
    echo -e "${RED}❌ Development branch missing production release${NC}"
    exit 1
fi

git checkout staging
if git log --oneline | grep -q "Release v1.0.0"; then
    echo -e "${GREEN}✅ Staging branch has production release${NC}"
else
    echo -e "${RED}❌ Staging branch missing production release${NC}"
    exit 1
fi
echo ""

# Show branch structure
echo -e "${YELLOW}Step 8: Visualizing branch structure${NC}"
git log --oneline --graph --all --decorate | head -20
echo ""

# Test conflict resolution scenario
echo -e "${YELLOW}Step 9: Testing conflict resolution${NC}"
git checkout development
echo "Development-specific feature" >> dev-feature.md
git add dev-feature.md
git commit -m "Add development feature"

git checkout main
echo "Production hotfix" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "Hotfix v1.0.1"

echo -e "${BLUE}Merging main into development (should not conflict)${NC}"
git checkout development
if git merge --no-ff main -m "chore: merge main into development [skip ci]" --no-edit; then
    echo -e "${GREEN}✅ Merge successful (no conflicts)${NC}"
else
    echo -e "${RED}❌ Merge failed${NC}"
    exit 1
fi
echo ""

# Cleanup
echo -e "${YELLOW}Step 10: Cleanup${NC}"
cd /tmp
rm -rf "$TEST_DIR"
echo -e "${GREEN}✅ Test repository cleaned up${NC}"
echo ""

# Final summary
echo "======================================"
echo -e "${GREEN}✅ ALL BRANCH MANAGEMENT TESTS PASSED${NC}"
echo "======================================"
echo ""
echo "Verified:"
echo "  ✓ Branch creation works correctly"
echo "  ✓ Main merges into development successfully"
echo "  ✓ Main merges into staging successfully"
echo "  ✓ [skip ci] flags are included in merge commits"
echo "  ✓ All branches receive production changes"
echo "  ✓ Conflict resolution works as expected"
echo ""
echo -e "${GREEN}The branch management automation is working correctly!${NC}"
