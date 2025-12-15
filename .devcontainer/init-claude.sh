#!/bin/bash
# Initialize Claude Code configuration
# This script sets hasCompletedOnboarding to true to skip the onboarding process

set -e

CLAUDE_CONFIG="${HOME}/.claude.json"

echo "Initializing Claude Code configuration..."

# Check if .claude.json exists
if [ -f "$CLAUDE_CONFIG" ]; then
    echo "Found existing .claude.json, updating..."
    # Read existing content, add hasCompletedOnboarding, and write back
    node --eval "
const fs = require('fs');
const filePath = '${CLAUDE_CONFIG}';
const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
content.hasCompletedOnboarding = true;
fs.writeFileSync(filePath, JSON.stringify(content, null, 2), 'utf-8');
console.log('Updated .claude.json with hasCompletedOnboarding: true');
"
else
    echo "Creating new .claude.json..."
    # Create new file with hasCompletedOnboarding
    cat > "$CLAUDE_CONFIG" << 'EOF'
{
  "hasCompletedOnboarding": true
}
EOF
    echo "Created .claude.json with hasCompletedOnboarding: true"
fi

echo "Claude Code initialization complete!"
