#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ANGULAR_DIR="angular-ui"

check_prerequisites() {
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}Error: npm is not installed. Please install Node.js and npm.${NC}"
        exit 1
    fi
}

start_frontend() {
    echo -e "${YELLOW}Starting Angular Frontend...${NC}"
    cd "$ANGULAR_DIR"
    
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}Installing dependencies (first run)...${NC}"
        npm install
    fi

    echo -e "${GREEN}Web UI will be available at http://localhost:4200${NC}"
    npm start
}

build_frontend() {
    echo -e "${YELLOW}Building Angular Frontend...${NC}"
    cd "$ANGULAR_DIR"
    npm install
    npm run build
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build successful! output in $ANGULAR_DIR/dist/${NC}"
    else
        echo -e "${RED}Build failed.${NC}"
        exit 1
    fi
}

test_frontend() {
    echo -e "${YELLOW}Running Angular Tests...${NC}"
    cd "$ANGULAR_DIR"
    npm test
}

# Main Execution Logic
check_prerequisites

case "$1" in
    start|"")
        start_frontend
        ;;
    build)
        build_frontend
        ;;
    test)
        test_frontend
        ;;
    *)
        echo -e "${RED}Usage: $0 {start|build|test}${NC}"
        exit 1
        ;;
esac
