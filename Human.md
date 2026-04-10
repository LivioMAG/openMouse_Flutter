cd /workspaces/openMouse_Flutter/openmouse
flutter config --enable-web
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
