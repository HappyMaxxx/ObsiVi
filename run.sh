#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Activate the virtual environment
if [ -d "$SCRIPT_DIR/venv" ]; then
    echo "Activating virtual environment..."
    source $SCRIPT_DIR/venv/bin/activate
else
    echo -e "${RED}Virtual environment not found! Please run install.sh first.${NC}"
    exit 1
fi

# Start the Flask server and the widget in the background
echo "Starting Flask server..."
nohup python3 $SCRIPT_DIR/app.py > $SCRIPT_DIR/flask.log 2>&1 &
FLASK_PID=$!
disown $FLASK_PID

sleep 2

# Start the widget
echo "Starting widget..."
nohup python3 $SCRIPT_DIR/flask_widget.py > $SCRIPT_DIR/widget.log 2>&1 &
WIDGET_PID=$!
disown $WIDGET_PID

echo "Done!"
