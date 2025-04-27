# Obsidian Desktop Widget

A small project to create a **desktop widget** that visualizes your **Obsidian Vault** as an interactive network graph.

The widget uses **Flask** to serve the application locally and **vis-network.js** to render the graph in a minimal webview.

## Features

- **Real-time Obsidian Vault visualization**
- **Desktop widget** with configurable size and position
- **Auto-refresh** of the graph when notes are updated
- **Systemd autostart support** (Linux)
- **Virtual environment** for Python dependencies
- **Minimal setup** with automatic installation scripts

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/HappyMaxxx/ObsiVi
   cd ObsiVi
   ```

2. **Run the installer:**

   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   Available options:

   - `-h` or `--help`: Show help message.
   - `-v <path>` or `--vault <path>`: Specify a custom path to your Obsidian Vault.

   Example:

   ```bash
   ./install.sh -v "/path/to/your/ObsidianVault"
   ```

3. **Follow on-screen instructions:**
   - Python and pip will be checked.
   - A virtual environment will be created.
   - Necessary Python libraries will be installed.
   - `vis-network.js` will be downloaded if missing.
   - Obsidian installation will be checked.
   - Configuration will be created (`conf.py`).
   - Optionally, systemd autostart can be set up.

## Requirements

- **Python 3.x**
- **pip**
- **Obsidian** installed on your system
- **Linux** (tested) – other systems might require small adjustments

## Usage

After installation:

- The widget will **start automatically** if you enabled autostart.
- Or you can manually launch it by running:

  ```bash
  ./run.sh
  ```

- The web app will be served at `http://localhost:5001`.
- The widget window will open automatically.

## Configuration

You can adjust some widget parameters by editing the `conf.py` file:

```python
OVP = "/path/to/your/ObsidianVault"  # Vault path
SD = "/path/to/project-directory"    # Script directory
x = 100  # X position of widget
y = 100  # Y position of widget
width = 400  # Width of widget
height = 300  # Height of widget
```

## Autostart Management

If you enabled autostart via systemd:

- **To stop the widget:**

  ```bash
  sudo systemctl stop obsidian_widget.service
  ```

- **To disable autostart:**

  ```bash
  sudo systemctl disable obsidian_widget.service
  sudo rm /etc/systemd/system/obsidian_widget.service
  sudo systemctl daemon-reload
  ```

## Project Structure

```
├── app.py           # Flask server
├── flask_widget.py  # PyQt6 widget app
├── main.py          # Script for getting graph files
├── install.sh       # Installation script
├── run.sh           # Script to launch the widget
├── stop.sh          # Script to stop the widget
├── requirements.txt # Python dependencies
├── libs/            # vis-network.js
├── templates/       # HTML templates
├── static/          # Images for widget
├── conf.py          # Configuration (created automatically)
```

## Notes

- The project is **optimized for Linux**. For Windows/macOS, minor modifications (especially around systemd) are needed.
- Internet connection is required for the first-time installation (to download vis-network.js).
- Make sure that your Obsidian Vault is **properly initialized** before running.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.