#!/bin/bash

# AST-Grep Rule Test Runner
# Tests each rule by checking if test files trigger the expected rule ID
# Test files should be named after the rule ID they test (e.g., my-rule.yml for rule id: my-rule)

find ~/.config/ast-grep/tests -name "*.yml" -o -name "*.yaml" | while read -r test_file; do
    expected_rule=$(basename "$test_file" | sed 's|\.yml$||;s|\.yaml$||')
    
    result=$(ast-grep scan --config ~/sgconfig.yml "$test_file" 2>&1)
    
    if echo "$result" | grep -q "error\[$expected_rule\]"; then
        echo "✓ $expected_rule"
    elif echo "$result" | grep -q "warning\[$expected_rule\]"; then
        echo "✓ $expected_rule (warning)"
    else
        echo "✗ $expected_rule"
    fi
done