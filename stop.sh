#!/bin/bash

# Stop the Flask server and the widget
if pgrep -f "python3 app.py" > /dev/null; then
    pkill -f "python3 app.py"
    echo -e "\nFlask server stopped."
else
    echo -e "\nFlask server not running."
fi

if pgrep -f "python3 flask_widget.py" > /dev/null; then
    pkill -f "python3 flask_widget.py"
    echo -e "Widget stopped."
else
    echo -e "Widget not running."
fi


echo "Done!"