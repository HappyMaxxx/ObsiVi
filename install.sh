#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "\nSTART..."

# Function to check if Python is installed
check_python() {
    echo -e "\n${BLUE}Checking if Python is installed...${NC}"
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
        echo -e "${GREEN}Python is installed.${NC}"
    else
        echo -e "${RED}Error: Python is not installed!"
        echo -e "Please install Python manually. Instructions:"
        echo -e "Linux (Debian/Ubuntu): sudo apt install python3"
        echo -e "Linux (Arch): sudo pacman -Sy python"
        echo -e "Linux (Fedora): sudo dnf install python3"
        echo -e "Windows: Download from https://www.python.org/${NC}"
        exit 1
    fi
}

# Function to create and activate a virtual environment if necessary
create_virtualenv() {
    echo -e "\n${BLUE}Creating or activating virtual environment...${NC}"
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    VENV_DIR="$SCRIPT_DIR/venv"

    # Check if virtual environment exists, if not, create it
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${BLUE}Creating virtual environment in $VENV_DIR...${NC}"
        $PYTHON_CMD -m venv "$VENV_DIR"
    fi

    # Activate the virtual environment
    echo -e "${BLUE}Activating virtual environment...${NC}"
    source "$VENV_DIR/bin/activate"
}

# Function to check and install required Python packages
install_pip_packages() {
    echo -e "\n${BLUE}Checking for pip...${NC}"
    if ! pip --version &>/dev/null; then
        echo -e "${RED}Error: pip is not installed in the virtual environment!"
        echo -e "Please ensure pip is installed in the virtual environment:"
        echo -e "Run 'python3 -m ensurepip --default-pip' to install pip.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Installing required Python packages...${NC}"
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    if [[ -f "$SCRIPT_DIR/requirements.txt" ]]; then
        if ! pip install -r "$SCRIPT_DIR/requirements.txt"; then
            echo -e "${RED}Error: Failed to install some Python packages!${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Warning: requirements.txt not found in $SCRIPT_DIR"
        echo -e "Please ensure the file exists and contains the required packages.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Python packages installed successfully."
    echo -e "Was installed:${NC}"
    pip list
    echo -e "${YELLOW}To deactivate the virtual environment, run 'deactivate'.${NC}"
}

# Function to check and install vis (network visualization library)
check_vis() {
    echo -e "\n${BLUE}Installing vis...${NC}"
    
    # Check if vis is already installed
    if [ -e "/libs/vis-network.min.js" ]; then
        echo -e "${GREEN}vis is already installed.${NC}"
    else
        # Download vis
        if wget https://unpkg.com/vis-network@9.1.2/dist/vis-network.min.js -O vis-network.min.js; then
            echo -e "${GREEN}vis installed successfully.${NC}"
        else
            echo -e "${RED}Error: Failed to download vis!${NC}"
            exit 1
        fi
    fi
}


# Function to check if Obsidian is installed
check_obsidian() {
    echo -e "\n${BLUE}Checking if Obsidian is installed...${NC}"
    command -v obsidian &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Obsidian is installed.${NC}"
    else
        echo -e "${RED}Error: Obsidian is not installed!"
        echo -e "Please install Obsidian manually. Instructions:"
        echo -e "Download from https://obsidian.md/${NC}"
        exit 1
    fi
}

# Main execution
check_python
create_virtualenv
install_pip_packages
check_vis
check_obsidian

echo -e "\nEND"
