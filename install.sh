#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Default path to Obsidian Vault
OBSIDIAN_VAULT_PATH="$HOME/Documents/Obsidian Vault"

# Function to handle command-line arguments
handle_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)  # Show help message
                echo -e "${GREEN}Usage: $0 [OPTIONS]${NC}"
                echo -e "\nOptions:"
                echo -e "  -h, --help        Show this help message"
                echo -e "  -v, --vault <path> Specify path to Obsidian Vault"
                exit 0
                ;;
            -v|--vault)  # Path to Obsidian Vault
                if [ -z "$2" ] || [ ! -d "$2" ]; then
                    echo -e "${RED}Error: Invalid path to Obsidian Vault!${NC}"
                    exit 1
                fi
                OBSIDIAN_VAULT_PATH="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Invalid option! Use -h for help.${NC}"
                exit 1
                ;;
        esac
    done
}

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

    echo -e "\n${BLUE}Running a quick test...${NC}"
    if ! python3 -c "import os" &>/dev/null; then
        echo -e "${RED}Test failed! Check your dependencies.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Test passed! Everything looks good.${NC}"
}

# Function to create and activate a virtual environment if necessary
create_virtualenv() {
    echo -e "\n${BLUE}Creating or activating virtual environment...${NC}"
    VENV_DIR="$SCRIPT_DIR/venv"

    # Check if virtual environment exists, if not, create it
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${BLUE}Creating virtual environment in $VENV_DIR...${NC}"
        $PYTHON_CMD -m venv "$VENV_DIR"
    fi

    # Activate the virtual environment
    if [ -d "$VENV_DIR" ]; then
        source "$VENV_DIR/bin/activate"
        echo -e "${GREEN}Virtual environment activated.${NC}"
    else
        echo -e "${RED}Error: Virtual environment not found!${NC}"
        exit 1
    fi
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
    if [ -e "$SCRIPT_DIR/libs/vis-network.min.js" ]; then
        echo -e "${GREEN}vis is already installed.${NC}"
    else
        # Download vis
        # Check internet connection
        ping -q -c 1 8.8.8.8 >/dev/null || { echo -e "${RED}No internet connection!${NC}"; exit 1; }

        if [ ! -d "$SCRIPT_DIR/libs" ]; then
            mkdir -p "$SCRIPT_DIR/libs"
        fi

        if wget https://unpkg.com/vis-network@9.1.2/dist/vis-network.min.js -O $SCRIPT_DIR/libs/vis-network.min.js; then
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

# Function to check if Obsidian Vault exists
check_obsi_path() {
    echo -e "\n${BLUE}Checking if Obsidian Vault exists...${NC}"
    if [ -e "$OBSIDIAN_VAULT_PATH" ]; then
        echo -e "${GREEN}Obsidian Vault already exists $OBSIDIAN_VAULT_PATH.${NC}"
    else
        echo -e "${RED}Error: Obsidian Vault is not created at $OBSIDIAN_VAULT_PATH!"
        echo -e "Please create Obsidian Vault manually or start script with flag -oP and your vault path.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}You can change the path to obsidian vault in conf.py${NC}"
}

fill_conf() {
    if ! echo "OVP = \"$OBSIDIAN_VAULT_PATH\"" > "$SCRIPT_DIR/conf.py"; then
        echo -e "${RED}Error: Failed to write to configuration file! (OVP)${NC}"
        exit 1
    fi

    if ! echo "SD = \"$SCRIPT_DIR\"" >> "$SCRIPT_DIR/conf.py"; then
        echo -e "${RED}Error: Failed to write to configuration file! (y)${NC}"
        exit 1
    fi

    if ! echo "x = 100" >> "$SCRIPT_DIR/conf.py"; then
        echo -e "${RED}Error: Failed to write to configuration file! (x)${NC}"
        exit 1
    fi

    if ! echo "y = 100" >> "$SCRIPT_DIR/conf.py"; then
        echo -e "${RED}Error: Failed to write to configuration file! (y)${NC}"
        exit 1
    fi

    echo -e "${GREEN}Configuration file created successfully.${NC}"
}

create_conf() {
    echo -e "\n${BLUE}Creating configuration file...${NC}"
    if [ -e "$SCRIPT_DIR/conf.py" ]; then
        fill_conf
    else
        if touch "$SCRIPT_DIR/conf.py"; then
            fill_conf
        else
            echo -e "${RED}Error: Failed to create configuration file!${NC}"
            exit 1
        fi
    fi
}

setup_autostart() {
    read -p "Do you want to add the script to autostart? (y/n): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        echo -e "${YELLOW}Autostart not configured. Exiting...${NC}"
        return
    fi

    SERVICE_PATH="/etc/systemd/system/obsidian_widget.service"
    if [ ! -f "$SERVICE_PATH" ]; then
        echo -e "${BLUE}Setting up systemd autostart...${NC}"
        sudo bash -c "cat > $SERVICE_PATH" <<EOL
[Unit]
Description=Autostart obsidian widget script
After=graphical.target

[Service]
Type=forking
User=$USER
WorkingDirectory=$SCRIPT_DIR
ExecStart=$SCRIPT_DIR/run.sh
Environment="DISPLAY=$DISPLAY"
Environment="XAUTHORITY=$HOME/.Xauthority"
Restart=always
RestartSec=5s

[Install]
WantedBy=default.target
EOL

        sudo systemctl daemon-reload
        sudo systemctl enable obsidian_widget.service
        echo -e "${GREEN}Autostart configured successfully!${NC}"
    else
        echo -e "${YELLOW}Autostart is already configured.${NC}"
    fi

    echo -e "${YELLOW}To stop the script, run 'sudo systemctl stop obsidian_widget.service'."
    echo -e "\nTo disable autostart, stop the script and:"
    echo -e "sudo systemctl disable obsidian_widget.service"
    echo -e "sudo rm /etc/systemd/system/obsidian_widget.service"
    echo -e "sudo systemctl daemon-reload${NC}\n"
}

handle_arguments "$@"

check_python
create_virtualenv
install_pip_packages
check_vis
check_obsidian
check_obsi_path
create_conf
setup_autostart

cd "$SCRIPT_DIR"
if ./run.sh; then
    echo -e "${GREEN}Installation script executed successfully.${NC}"
else
    echo -e "${RED}Error: Failed to execute installation script!${NC}"
    exit 1
fi
