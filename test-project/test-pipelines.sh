#!/bin/bash

# CI/CD Pipeline Testing Script
# Tests all pipeline templates for proper branch configuration and workflow execution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(cd "$SCRIPT_DIR/../change-control" && pwd)"

echo "======================================"
echo "CI/CD Pipeline Template Validator"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}TEST $TESTS_TOTAL: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo ""
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo ""
        return 1
    fi
}

# Test 1: Verify all template files exist
echo -e "${YELLOW}=== Phase 1: Template Files Validation ===${NC}"
echo ""

run_test "Node.js template exists" \
    "test -f '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Python template exists" \
    "test -f '$TEMPLATES_DIR/pipeline-python-template.yml'"

run_test "Generic template exists" \
    "test -f '$TEMPLATES_DIR/pipeline-generic-template.yml'"

# Test 2: Verify branch configurations
echo -e "${YELLOW}=== Phase 2: Branch Configuration Tests ===${NC}"
echo ""

run_test "Node.js template has all three branches in push trigger" \
    "grep -q 'branches: \[ main, staging, development \]' '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Python template has all three branches in push trigger" \
    "grep -q 'branches: \[ main, staging, development \]' '$TEMPLATES_DIR/pipeline-python-template.yml'"

run_test "Generic template has all three branches in push trigger" \
    "grep -q 'branches: \[ main, staging, development \]' '$TEMPLATES_DIR/pipeline-generic-template.yml'"

# Test 3: Verify staging deployment conditions
echo -e "${YELLOW}=== Phase 3: Staging Deployment Tests ===${NC}"
echo ""

run_test "Node.js template deploys to staging on development branch" \
    "grep -q \"github.ref == 'refs/heads/development'\" '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Node.js template deploys to staging on staging branch" \
    "grep -q \"github.ref == 'refs/heads/staging'\" '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Python template has correct staging deployment condition" \
    "grep -q \"if: github.ref == 'refs/heads/development' || github.ref == 'refs/heads/staging'\" '$TEMPLATES_DIR/pipeline-python-template.yml'"

run_test "Generic template has correct staging deployment condition" \
    "grep -q \"if: github.ref == 'refs/heads/development' || github.ref == 'refs/heads/staging'\" '$TEMPLATES_DIR/pipeline-generic-template.yml'"

# Test 4: Verify production deployment conditions
echo -e "${YELLOW}=== Phase 4: Production Deployment Tests ===${NC}"
echo ""

run_test "Node.js template deploys to production only on main" \
    "grep -A5 'deploy-production:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q \"github.ref == 'refs/heads/main'\""

run_test "Python template deploys to production only on main" \
    "grep -A5 'deploy-production:' '$TEMPLATES_DIR/pipeline-python-template.yml' | grep -q \"github.ref == 'refs/heads/main'\""

run_test "Generic template deploys to production only on main" \
    "grep -A5 'deploy-production:' '$TEMPLATES_DIR/pipeline-generic-template.yml' | grep -q \"github.ref == 'refs/heads/main'\""

# Test 5: Verify job dependencies
echo -e "${YELLOW}=== Phase 5: Job Dependency Tests ===${NC}"
echo ""

run_test "Node.js staging deployment depends on quality-gates and testing" \
    "grep -A3 'deploy-staging:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q 'needs: \[quality-gates, testing\]'"

run_test "Node.js production deployment depends on quality-gates and testing" \
    "grep -A3 'deploy-production:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q 'needs: \[quality-gates, testing\]'"

run_test "Python staging deployment depends on quality-gates" \
    "grep -A3 'deploy-staging:' '$TEMPLATES_DIR/pipeline-python-template.yml' | grep -q 'needs: quality-gates'"

run_test "Python production deployment depends on quality-gates" \
    "grep -A3 'deploy-production:' '$TEMPLATES_DIR/pipeline-python-template.yml' | grep -q 'needs: quality-gates'"

# Test 6: Verify environment configurations
echo -e "${YELLOW}=== Phase 6: Environment Configuration Tests ===${NC}"
echo ""

run_test "Node.js staging job has staging environment" \
    "grep -A10 'deploy-staging:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q 'environment: staging'"

run_test "Node.js production job has production environment" \
    "grep -A10 'deploy-production:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q 'environment: production'"

run_test "Python staging job has staging environment" \
    "grep -A10 'deploy-staging:' '$TEMPLATES_DIR/pipeline-python-template.yml' | grep -q 'environment: staging'"

run_test "Python production job has production environment" \
    "grep -A10 'deploy-production:' '$TEMPLATES_DIR/pipeline-python-template.yml' | grep -q 'environment: production'"

# Test 7: Verify branch management automation
echo -e "${YELLOW}=== Phase 7: Branch Management Automation Tests ===${NC}"
echo ""

run_test "Node.js template has branch management job" \
    "grep -q 'branch-management:' '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Branch management only runs on main branch push" \
    "grep -A3 'branch-management:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q \"github.ref == 'refs/heads/main' && github.event_name == 'push'\""

run_test "Branch management has write permissions" \
    "grep -A5 'branch-management:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q 'contents: write'"

run_test "Branch management fetches full git history" \
    "grep -A15 'branch-management:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q 'fetch-depth: 0'"

run_test "Branch management includes skip ci flag" \
    "grep -q '\[skip ci\]' '$TEMPLATES_DIR/pipeline-template.yml'"

# Test 8: Verify YAML syntax
echo -e "${YELLOW}=== Phase 8: YAML Syntax Validation ===${NC}"
echo ""

if command -v yamllint &> /dev/null; then
    run_test "Node.js template has valid YAML syntax" \
        "yamllint -d relaxed '$TEMPLATES_DIR/pipeline-template.yml'"
    
    run_test "Python template has valid YAML syntax" \
        "yamllint -d relaxed '$TEMPLATES_DIR/pipeline-python-template.yml'"
    
    run_test "Generic template has valid YAML syntax" \
        "yamllint -d relaxed '$TEMPLATES_DIR/pipeline-generic-template.yml'"
else
    echo -e "${YELLOW}⚠️  yamllint not installed, skipping YAML syntax validation${NC}"
    echo -e "${YELLOW}   Install with: pip install yamllint${NC}"
    echo ""
fi

# Test 9: Verify quality gates
echo -e "${YELLOW}=== Phase 9: Quality Gates Tests ===${NC}"
echo ""

run_test "Node.js template has quality-gates job" \
    "grep -q 'quality-gates:' '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Python template has quality-gates job" \
    "grep -q 'quality-gates:' '$TEMPLATES_DIR/pipeline-python-template.yml'"

run_test "Generic template has quality-gates job" \
    "grep -q 'quality-gates:' '$TEMPLATES_DIR/pipeline-generic-template.yml'"

run_test "Node.js template checks out code" \
    "grep -A20 'quality-gates:' '$TEMPLATES_DIR/pipeline-template.yml' | grep -q 'actions/checkout@v4'"

# Test 10: Verify proper action versions
echo -e "${YELLOW}=== Phase 10: GitHub Actions Version Tests ===${NC}"
echo ""

run_test "Node.js template uses checkout@v4" \
    "grep -q 'actions/checkout@v4' '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Node.js template uses setup-node@v4" \
    "grep -q 'actions/setup-node@v4' '$TEMPLATES_DIR/pipeline-template.yml'"

run_test "Python template uses checkout@v4" \
    "grep -q 'actions/checkout@v4' '$TEMPLATES_DIR/pipeline-python-template.yml'"

run_test "Python template uses setup-python@v5" \
    "grep -q 'actions/setup-python@v5' '$TEMPLATES_DIR/pipeline-python-template.yml'"

# Final Summary
echo "======================================"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo "======================================"
echo -e "Total Tests:  $TESTS_TOTAL"
echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
echo "======================================"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}The pipeline templates are ready for production use.${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED!${NC}"
    echo -e "${RED}Please review the failures above and fix the templates.${NC}"
    exit 1
fi
