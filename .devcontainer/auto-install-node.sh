#!/bin/bash
# Auto-install Node.js version based on version control files

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Node.js Auto-Installer ===${NC}"

# Load nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
else
    echo -e "${YELLOW}Warning: nvm not found${NC}"
    exit 0
fi

# Function to extract node version from package.json
extract_node_from_package_json() {
    if [ -f "package.json" ]; then
        # Try to extract version from engines.node field
        local version=$(node -e "
            try {
                const pkg = require('./package.json');
                const engines = pkg.engines?.node;
                if (engines) {
                    // Remove common version prefixes and get the version
                    const match = engines.match(/(\d+\.\d+\.\d+)/);
                    if (match) {
                        console.log(match[1]);
                    } else {
                        // Try to extract major version like '>=18' or '^18.0.0'
                        const majorMatch = engines.match(/(\d+)/);
                        if (majorMatch) {
                            console.log(majorMatch[1]);
                        }
                    }
                }
            } catch(e) {}
        " 2>/dev/null || echo "")

        if [ -n "$version" ]; then
            echo "$version"
        fi
    fi
}

# Function to normalize version (handle partial versions)
normalize_version() {
    local version="$1"

    # Remove 'v' prefix if present
    version="${version#v}"

    # If only major version (e.g., "18"), find the latest installed matching version
    if [[ "$version" =~ ^[0-9]+$ ]]; then
        # Try to find installed version matching this major version
        local installed=$(nvm list | grep "v$version\." | head -1 | sed 's/.*v\([0-9.]*\).*/\1/')
        if [ -n "$installed" ]; then
            echo "$installed"
            return
        fi
        # If not installed, return as is
        echo "$version"
        return
    fi

    echo "$version"
}

# Function to install node version and its tools
install_node_and_tools() {
    local version="$1"
    local normalized_version=$(normalize_version "$version")

    echo -e "${BLUE}Checking Node.js version: ${normalized_version}${NC}"

    # Check if version is already installed
    if nvm list | grep -q "v${normalized_version}"; then
        echo -e "${GREEN}✓ Node.js ${normalized_version} is already installed${NC}"
        return 0
    fi

    echo -e "${YELLOW}Installing Node.js ${normalized_version}...${NC}"

    # If it's a major version only, try to install the latest for that major
    if [[ "$normalized_version" =~ ^[0-9]+$ ]]; then
        echo -e "${BLUE}Fetching latest version for Node.js ${normalized_version}.x...${NC}"
        nvm install "${normalized_version}" || {
            echo -e "${YELLOW}Warning: Could not install Node.js ${normalized_version}${NC}"
            return 1
        }
    else
        nvm install "${normalized_version}" || {
            echo -e "${YELLOW}Warning: Could not install Node.js ${normalized_version}${NC}"
            return 1
        }
    fi

    # Use the newly installed version
    nvm use "${normalized_version}"

    # Install pnpm and yarn for this version
    echo -e "${BLUE}Installing pnpm and yarn for Node.js ${normalized_version}...${NC}"
    npm install -g pnpm yarn 2>/dev/null || {
        echo -e "${YELLOW}Warning: Could not install pnpm/yarn for Node.js ${normalized_version}${NC}"
    }

    echo -e "${GREEN}✓ Node.js ${normalized_version} installed successfully${NC}"
}

# Function to detect and install from version files
detect_and_install() {
    local version=""
    local source=""

    # Check for .nvmrc
    if [ -f ".nvmrc" ]; then
        version=$(cat .nvmrc | tr -d '[:space:]')
        source=".nvmrc"
    # Check for .node-version
    elif [ -f ".node-version" ]; then
        version=$(cat .node-version | tr -d '[:space:]')
        source=".node-version"
    # Check for .tool-versions (asdf format)
    elif [ -f ".tool-versions" ]; then
        version=$(grep "^nodejs" .tool-versions | awk '{print $2}' | tr -d '[:space:]')
        if [ -z "$version" ]; then
            version=$(grep "^node" .tool-versions | awk '{print $2}' | tr -d '[:space:]')
        fi
        if [ -n "$version" ]; then
            source=".tool-versions"
        fi
    # Check for package.json engines.node
    elif [ -f "package.json" ]; then
        version=$(extract_node_from_package_json)
        if [ -n "$version" ]; then
            source="package.json (engines.node)"
        fi
    fi

    if [ -n "$version" ]; then
        echo -e "${GREEN}Found Node.js version ${version} in ${source}${NC}"
        install_node_and_tools "$version"

        # Set as default if not using a major version only
        local normalized=$(normalize_version "$version")
        if [[ "$normalized" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            nvm alias default "$normalized" 2>/dev/null || true
            echo -e "${GREEN}✓ Set Node.js ${normalized} as default${NC}"
        fi
    else
        echo -e "${BLUE}No Node.js version file found in current directory${NC}"
        echo -e "${BLUE}Supported files: .nvmrc, .node-version, .tool-versions, package.json${NC}"
    fi
}

# Main execution
cd /workspace 2>/dev/null || cd ~

detect_and_install

echo -e "${BLUE}Current Node.js version: $(node --version)${NC}"
echo -e "${GREEN}=== Node.js Auto-Installer Complete ===${NC}"
