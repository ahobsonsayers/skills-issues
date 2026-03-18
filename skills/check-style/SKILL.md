---
name: check-style
description: |
  Check LLM-written code against style rules using ast-grep. Use this skill whenever:
  - The user asks to check code style or conformance to style rules
  - The user mentions ast-grep or code linting
  - The user wants to validate code against custom style guidelines
  - The user asks to create, update, or modify ast-grep rules
  - Code needs to be validated before being considered complete
  - The user mentions enforcing coding standards or style guides
  
  This skill helps ensure all generated code conforms to project-specific or global ast-grep style rules.
---

# Check Style

This skill helps you check LLM-written code against style rules using ast-grep, and assists in creating or updating those rules.

## Overview

Ast-grep is a powerful tool for searching and rewriting code using abstract syntax trees (AST). This skill ensures that:
1. All code you write is checked against style rules
2. Style rules are properly organized and maintained
3. New rules can be created from natural language descriptions

## Directory Structure

The ast-grep configuration follows this structure:

```
~/
├── sgconfig.yml
└── .config/ast-grep/
    ├── run-tests.sh                    # Test runner script
    ├── tests/                          # Test files for rules
    │   ├── go/
    │   │   ├── go-code-style.yml       # Named after rule id: go-code-style
    │   │   └── ...
    │   └── [language]/
    │       └── [rule-id].[ext]         # Test file named after rule id
    └── rules/
        ├── go/
        │   └── go-code-style.yml       # Contains: id: go-code-style
        └── [language]/
            └── [rule-name].yml
```

### sgconfig.yml

The root configuration file should contain:

```yaml
ruleDirs:
  - .config/ast-grep/rules
```

## Workflow

### When the Skill is Invoked Without Additional Content

If the user invokes this skill with no additional content (e.g., just "/check-style" or "check style"), **immediately run ast-grep against the current working directory**. Do not wait for code or ask what to check - scan the existing files right away.

1. Run ast-grep to scan the current working directory:
   ```bash
   ast-grep scan
   ```
2. Report any violations found to the user
3. If no global config exists at `~/.config/ast-grep/`, inform the user and offer to set up the standard global structure

**Important**: 
- Only use the global ast-grep configuration. Never create project-specific `sgconfig.yml` files.
- This skill checks existing code files in the current directory, not code provided by the user.

### When Writing Code

**Always run ast-grep on code before considering it complete.**

1. Run ast-grep to check the code:
   ```bash
   ast-grep scan [file-or-directory]
   ```
2. If violations are found, fix them before presenting the code to the user
3. If the violations reveal missing rules, consider creating new ones in the global config

**Important**: Only use the global ast-grep configuration at `~/.config/ast-grep/`. Never create project-specific `sgconfig.yml` files.

### When Creating or Updating Rules

1. Identify the language the rule applies to
2. Ensure the language-specific directories exist:
   ```bash
   mkdir -p ~/.config/ast-grep/rules/[language]
   mkdir -p ~/.config/ast-grep/tests/[language]
   
   # Also ensure the run-tests.sh script exists
   if [ ! -f ~/.config/ast-grep/run-tests.sh ]; then
       cp ~/.agents/skills/check-style/run-tests.sh ~/.config/ast-grep/run-tests.sh
       chmod +x ~/.config/ast-grep/run-tests.sh
   fi
   ```
3. Use the `/ast-grep` skill to convert the user's description into a proper ast-grep rule
4. Save the rule to the appropriate location:
   `~/.config/ast-grep/rules/[language]/[descriptive-name].yml`
5. **Create or update test files** in `~/.config/ast-grep/tests/[language]/`:
   - Create `[rule-name]-violations.*` with intentional violations
   - Create `[rule-name]-correct.*` with proper code that should pass
6. **Test the rule** against both test files (see Testing Rules section below)
7. **Run the full test suite**: `~/.config/ast-grep/run-tests.sh`

**Note**: Only read rule files when creating or updating rules. For normal style checking, simply run `ast-grep scan` and let it use the global configuration.

### Testing Rules

**CRITICAL**: Every rule must be validated against test files to ensure it works correctly.

1. Create test files in `~/.config/ast-grep/tests/[language]/` with:
   - Example code containing violations (should trigger errors/warnings)
   - Example code that is correct (should NOT trigger any violations)

2. Test each rule file against violation examples:
   ```bash
   ast-grep scan -r ~/.config/ast-grep/rules/[language]/[rule-file].yml ~/.config/ast-grep/tests/[language]/test-violations.[ext]
   ```
   Expected: Errors/warnings should be flagged

3. Test each rule file against correct examples:
   ```bash
   ast-grep scan -r ~/.config/ast-grep/rules/[language]/[rule-file].yml ~/.config/ast-grep/tests/[language]/test-correct.[ext]
   ```
   Expected: No violations (empty output or exit code 0)

4. If a rule fails either test:
   - Fix the rule pattern/regex
   - Re-test until both conditions pass
   - Never mark a rule as complete without passing both tests

5. After updating existing rules:
   - Re-run tests to ensure they still work
   - Check for new false positives on correct code
   - Verify violations are still caught

6. Always maintain and update tests:
   - Tests live in `~/.config/ast-grep/tests/` alongside the rules
   - When modifying rules, update tests to cover new cases
   - When rules are removed, remove corresponding tests

### Running All Tests

Use the provided test script to run all tests:

```bash
~/.config/ast-grep/run-tests.sh
```

This runs tests for all rule files and produces a summary of pass/fail results.

### Example Test File Structure

```
~/.config/ast-grep/tests/
├── github-actions/
│   ├── test-yaml-structure-violations.yml    # Contains intentional violations
│   ├── test-yaml-structure-correct.yml        # Contains properly formatted code
│   ├── test-job-ordering-violations.yml
│   ├── test-job-ordering-correct.yml
│   └── ...
├── go/
│   ├── test-violations.go
│   └── test-correct.go
└── javascript/
    ├── test-violations.js
    └── test-correct.js
```

Each test file should include multiple test cases covering:
- Clear violations that should be caught
- Edge cases where the rule might incorrectly trigger
- Correct code that should pass without violations

### Rule Organization

- Each language gets its own folder: `[language]/`
- Rule files should have descriptive names (e.g., `no-console-log.yml`, `prefer-const.yml`)
- Group related rules in the same file when it makes sense
- Use comments in rule files to explain the purpose

## Example Rule File

```yaml
id: prefer-const-over-let
language: javascript
message: "Use const instead of let when the variable is never reassigned"
severity: warning
rule:
  pattern: let $NAME = $INIT
constraints:
  NAME:
    pattern: $NAME
fix: |
  const $NAME = $INIT
```

## Running Ast-grep

**Important**: Always use the `ast-grep` command, not `sg`. The `sg` alias has name collisions with other tools.

### Basic Scan
```bash
ast-grep scan [path]
```

### Scan with specific rules
```bash
ast-grep scan --rule [rule-file] [path]
```



## Best Practices

1. **Always check code**: Run ast-grep on all code you write before presenting it
2. **Global config only**: Only use the global ast-grep configuration at `~/.config/ast-grep/`. Never create project-specific `sgconfig.yml` files
3. **Use the /ast-grep skill**: When the user describes a style rule in natural language, invoke the ast-grep skill to convert it to proper YAML
4. **Organize by language**: Keep rules for different languages in separate directories
5. **Test all rules**: Every rule must have a test file named after its rule ID in `~/.config/ast-grep/tests/[language]/[rule-id].[ext]`
6. **Test naming must match**: The test filename (e.g., `my-rule.go`) must match the rule's `id:` field (e.g., `id: my-rule`)
7. **Don't check installation**: Simply run `ast-grep scan` - if ast-grep is not installed, the command will fail and you'll know
8. **Use ast-grep command**: Always use `ast-grep` instead of `sg` - the `sg` alias has name collisions with other tools
9. **Validate after updates**: When modifying existing rules, re-run tests (`~/.config/ast-grep/run-tests.sh`) to ensure they still catch violations

## Common Patterns

### Checking a file after writing it
```bash
# After writing code to a file
ast-grep scan src/myfile.js

# If violations exist, fix them and re-scan
```

### Creating a new rule from description
```
User: "I want a rule that prevents using console.log in production code"

Action: Invoke /ast-grep skill with the description
Result: Save the generated rule to ~/.config/ast-grep/rules/javascript-rules/no-console-log.yml
```

### Setting up Global Ast-grep Configuration

If the global ast-grep configuration doesn't exist, create it in the home directory:

```bash
# Create global config structure
mkdir -p ~/.config/ast-grep/rules
mkdir -p ~/.config/ast-grep/tests

# Copy the bundled run-tests.sh script
cp ~/.agents/skills/check-style/run-tests.sh ~/.config/ast-grep/run-tests.sh
chmod +x ~/.config/ast-grep/run-tests.sh

# Create sgconfig.yml in home directory
cat > ~/sgconfig.yml << 'EOF'
ruleDirs:
  - .config/ast-grep/rules
EOF
```

**Important**: This creates a global configuration only. Never create project-specific `sgconfig.yml` files. Always copy the bundled run-tests.sh when setting up a new config location.
