from PyQt6.QtWidgets import QApplication, QMainWindow, QVBoxLayout, QWidget, QSystemTrayIcon, QMenu
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtCore import Qt, QUrl, QPoint
from PyQt6.QtGui import QIcon, QAction
import sys, os
import platform

from conf import *

class DragHandle(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.setFixedSize(50, 50)
        self.setStyleSheet("background-color: rgba(0, 0, 0, 0);")
        self.old_pos = None

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.old_pos = event.globalPosition().toPoint()

    def mouseMoveEvent(self, event):
        if self.old_pos:
            delta = event.globalPosition().toPoint() - self.old_pos
            new_x = self.parent().x() + delta.x()
            new_y = self.parent().y() + delta.y()

            screen_geometry = QApplication.primaryScreen().availableGeometry()
            window_geometry = self.parent().frameGeometry()

            if new_x < screen_geometry.left():
                new_x = screen_geometry.left()
            if new_x + window_geometry.width() > screen_geometry.right() + 1:
                new_x = screen_geometry.right() - window_geometry.width() + 1
            if new_y < screen_geometry.top():
                new_y = screen_geometry.top()
            if new_y + window_geometry.height() > screen_geometry.bottom() + 1:
                new_y = screen_geometry.bottom() - window_geometry.height() + 1

            self.parent().move(new_x, new_y)
            self.old_pos = event.globalPosition().toPoint()
        
            self.parent().save_position(new_x, new_y)

    def mouseReleaseEvent(self, event):
        self.old_pos = None

    def enterEvent(self, event):
        self.setStyleSheet("background-color: rgba(0, 0, 0, 50);")

    def leaveEvent(self, event):
        self.setStyleSheet("background-color: rgba(0, 0, 0, 0);")


class ResizeHandle(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.setFixedSize(20, 20)
        self.setStyleSheet("background-color: rgba(0, 0, 0, 0);")
        self.old_pos = None

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.old_pos = event.globalPosition().toPoint()

    def mouseMoveEvent(self, event):
        if self.old_pos:
            delta = event.globalPosition().toPoint() - self.old_pos
            new_width = self.parent().width() + delta.x()
            new_height = self.parent().height() + delta.y()

            min_width = 200
            min_height = 150
            new_width = max(new_width, min_width)
            new_height = max(new_height, min_height)

            screen_geometry = QApplication.primaryScreen().availableGeometry()
            window_pos = self.parent().pos()

            if window_pos.x() + new_width > screen_geometry.right() + 1:
                new_width = screen_geometry.right() - window_pos.x() + 1
            if window_pos.y() + new_height > screen_geometry.bottom() + 1:
                new_height = screen_geometry.bottom() - window_pos.y() + 1

            self.parent().resize(new_width, new_height)
            self.old_pos = event.globalPosition().toPoint()
            
            self.parent().resize_handle.move(new_width - 20, new_height - 20)
            self.parent().save_size(new_width, new_height)

    def mouseReleaseEvent(self, event):
        self.old_pos = None

    def enterEvent(self, event):
        self.setStyleSheet("background-color: rgba(0, 0, 0, 50);")
        self.setCursor(Qt.CursorShape.SizeFDiagCursor)

    def leaveEvent(self, event):
        self.setStyleSheet("background-color: rgba(0, 0, 0, 0);")
        self.setCursor(Qt.CursorShape.ArrowCursor)


class WebWidget(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Flask Widget")
        self.setGeometry(100, 100, width, height)

        self.set_position()

        self.browser = QWebEngineView()
        self.browser.setUrl(QUrl("http://127.0.0.1:5001"))

        container = QWidget(self)
        layout = QVBoxLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self.browser)

        self.drag_handle = DragHandle(self)
        self.drag_handle.move(0, 0)

        self.resize_handle = ResizeHandle(self)
        self.resize_handle.move(self.width() - 20, self.height() - 20)

        container.setLayout(layout)
        self.setCentralWidget(container)

        self.setWindowFlags(Qt.WindowType.FramelessWindowHint |
                            Qt.WindowType.Tool |
                            Qt.WindowType.WindowStaysOnBottomHint)

        self.tray_icon = QSystemTrayIcon(self)
        icon_path = os.path.join(os.path.dirname(__file__), 'static', 'obsidian-icon.ico') if platform.system() == "Windows" else os.path.join(os.path.dirname(__file__), 'static', 'obsidian-icon.png')
        self.tray_icon.setIcon(QIcon(icon_path))

        self.tray_icon.setVisible(True)

        self.tray_menu = QMenu()
        show_action = QAction("Show", self)
        quit_action = QAction("Exit", self)
        show_action.triggered.connect(self.show)
        quit_action.triggered.connect(self.quit_app)
        self.tray_menu.addAction(show_action)
        self.tray_menu.addAction(quit_action)
        self.tray_icon.setContextMenu(self.tray_menu)

        self.hide()

    def quit_app(self):
        os.system("bash stop.sh")
        QApplication.quit()

    def set_position(self):
        self.move(x, y)

    def save_position(self, x, y):
        file_path = os.path.join(SD, 'conf.py')
        with open(file_path , "r") as file:
            lines = file.readlines()
        with open(file_path , "w") as file:
            for line in lines:
                if line.startswith("x ="):
                    file.write(f"x = {x}\n")
                elif line.startswith("y ="):
                    file.write(f"y = {y}\n")
                else:
                    file.write(line)

    def save_size(self, width, height):
        file_path = os.path.join(SD, 'conf.py')
        with open(file_path , "r") as file:
            lines = file.readlines()
        with open(file_path , "w") as file:
            for line in lines:
                if line.startswith("width ="):
                    file.write(f"width = {width}\n")
                elif line.startswith("height ="):
                    file.write(f"height = {height}\n")
                else:
                    file.write(line)
        
    def closeEvent(self, event):
        event.ignore()
        self.hide()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = WebWidget()
    widget.show()
    sys.exit(app.exec())
