#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "============================================================================"
echo "STACKS-SKILLS COMPREHENSIVE TEST SUITE"
echo "============================================================================"
echo

echo "Checking all contracts for syntax errors..."
echo

# Check each contract
contracts=("constants" "oracle" "skillflow-main" "skills-token" "utils")
failed_contracts=()

for i in "${!contracts[@]}"; do
    contract=${contracts[$i]}
    echo "[$(($i+1))/${#contracts[@]}] Checking ${contract}.clar..."
    
    if clarinet check contracts/${contract}.clar > /dev/null 2>&1; then
        echo -e "✅ ${GREEN}PASSED${NC}: ${contract}.clar syntax is valid"
    else
        echo -e "❌ ${RED}FAILED${NC}: ${contract}.clar has syntax errors"
        failed_contracts+=($contract)
    fi
    echo
done

if [ ${#failed_contracts[@]} -eq 0 ]; then
    echo "============================================================================"
    echo -e "${GREEN}ALL CONTRACTS PASSED SYNTAX CHECK ✅${NC}"
    echo "============================================================================"
else
    echo "============================================================================"
    echo -e "${RED}FAILED CONTRACTS: ${failed_contracts[*]}${NC}"
    echo "Please fix syntax errors before proceeding with tests"
    echo "============================================================================"
    exit 1
fi

echo
echo "Available Testing Options:"
echo
echo "[1] Run existing TypeScript/JavaScript tests (if any)"
echo "[2] Start manual console testing for Oracle contract"
echo "[3] Start manual console testing for SkillFlow Main contract"
echo "[4] Start manual console testing for Skills Token contract"
echo "[5] Run all automated tests (requires Clarinet 2.11+)"
echo "[6] Check existing test files"
echo "[7] Exit"
echo

read -p "Enter your choice (1-7): " choice

case $choice in
    1)
        echo
        echo "============================================================================"
        echo "RUNNING EXISTING TESTS"
        echo "============================================================================"
        echo
        
        # Check for npm/vitest tests first
        if [ -f "package.json" ]; then
            echo "Found package.json - checking for npm test scripts..."
            if grep -q "test" package.json; then
                echo "Found test scripts in package.json"
                echo "Attempting to run npm tests..."
                npm test
            else
                echo "No test scripts found in package.json"
            fi
        fi
        
        # Try clarinet test
        echo
        echo "Attempting clarinet test..."
        if clarinet test > /dev/null 2>&1; then
            clarinet test
            echo -e "${GREEN}✅ All automated tests completed successfully!${NC}"
        else
            echo -e "${YELLOW}⚠️  'clarinet test' command not available or failed${NC}"
            echo
            echo "This usually means:"
            echo "  1. You have Clarinet 2.7.0 which doesn't support 'clarinet test'"
            echo "  2. No test files are properly configured"
            echo "  3. Test files have syntax errors"
            echo
            echo "Recommendation: Use manual console testing (options 2-4) or upgrade Clarinet"
        fi
        ;;
    
    2)
        echo
        echo "============================================================================"
        echo "STARTING MANUAL ORACLE CONTRACT TESTING"
        echo "============================================================================"
        echo
        echo "Opening clarinet console for Oracle contract testing..."
        echo
        echo -e "${BLUE}📋 Reference commands:${NC}"
        echo "  (contract-call? .oracle update-stx-price u2500000 \"coinbase\" u95 u500)"
        echo "  (contract-call? .oracle get-current-stx-price)"
        echo "  (contract-call? .oracle convert-stx-to-usd u1000000)"
        echo
        echo "Press Enter to start console..."
        read
        clarinet console
        ;;
    
    3)
        echo
        echo "============================================================================"
        echo "STARTING MANUAL SKILLFLOW-MAIN CONTRACT TESTING"
        echo "============================================================================"
        echo
        echo "Opening clarinet console for SkillFlow Main contract testing..."
        echo
        echo -e "${BLUE}💡 Example test commands:${NC}"
        echo "  (contract-call? .skillflow-main create-service \"Web Development\" u5000000 u144 \"Build a website\")"
        echo "  (contract-call? .skillflow-main get-service-count)"
        echo
        echo "Press Enter to start console..."
        read
        clarinet console
        ;;
    
    4)
        echo
        echo "============================================================================"
        echo "STARTING MANUAL SKILLS-TOKEN CONTRACT TESTING"
        echo "============================================================================"
        echo
        echo "Opening clarinet console for Skills Token contract testing..."
        echo
        echo -e "${BLUE}💡 Example test commands:${NC}"
        echo "  (contract-call? .skills-token get-name)"
        echo "  (contract-call? .skills-token get-symbol)"
        echo "  (contract-call? .skills-token get-total-supply)"
        echo
        echo "Press Enter to start console..."
        read
        clarinet console
        ;;
    
    5)
        echo
        echo "============================================================================"
        echo "ATTEMPTING AUTOMATED TESTS"
        echo "============================================================================"
        echo
        echo "Checking Clarinet version..."
        clarinet --version
        echo
        
        echo "Attempting to run automated tests..."
        if clarinet test; then
            echo
            echo -e "${GREEN}✅ All automated tests completed successfully!${NC}"
        else
            echo
            echo -e "${RED}❌ Automated tests failed or 'clarinet test' command not available${NC}"
            echo
            echo "This usually means:"
            echo "  1. You have Clarinet 2.7.0 which doesn't support 'clarinet test'"
            echo "  2. No test files are properly configured"
            echo "  3. Test files have syntax errors"
            echo
            echo "Recommendation: Use manual console testing (options 2-4) or upgrade Clarinet"
        fi
        ;;
    
    6)
        echo
        echo "============================================================================"
        echo "CHECKING EXISTING TEST FILES"
        echo "============================================================================"
        echo
        
        if [ -d "tests" ]; then
            echo "Contents of tests/ directory:"
            ls -la tests/
            echo
            
            ts_files=$(find tests/ -name "*.ts" 2>/dev/null)
            js_files=$(find tests/ -name "*.js" 2>/dev/null)
            
            if [ ! -z "$ts_files" ]; then
                echo -e "${BLUE}Found TypeScript test files:${NC}"
                echo "$ts_files"
                echo
            fi
            
            if [ ! -z "$js_files" ]; then
                echo -e "${BLUE}Found JavaScript test files:${NC}"
                echo "$js_files"
                echo
            fi
            
            if [ -z "$ts_files" ] && [ -z "$js_files" ]; then
                echo "No TypeScript or JavaScript test files found"
            fi
        else
            echo "No tests/ directory found"
        fi
        
        if [ -f "package.json" ]; then
            echo
            echo "Checking package.json for test scripts..."
            if grep -q "test" package.json; then
                echo -e "${GREEN}Found test scripts in package.json${NC}"
                grep -A 5 -B 5 "test" package.json
            else
                echo "No test scripts found in package.json"
            fi
        fi
        ;;
    
    7)
        echo "Exiting..."
        exit 0
        ;;
    
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

echo
echo "============================================================================"
echo "TESTING COMPLETE"
echo "============================================================================"
echo
echo "Summary of what was checked:"
echo "✅ All contract syntax validation passed"
echo "📋 Test options were presented based on your Clarinet version"
echo
echo "For future testing:"
echo "  - Manual: Run this script and choose console testing options"
echo "  - Automated: Upgrade to Clarinet 2.11+ for 'clarinet test' support"
echo
echo -e "${GREEN}Thank you for testing your Stacks smart contracts! 🚀${NC}"