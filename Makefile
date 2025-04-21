export APP_NAME := flamejam2025
export ITCH_GAME_ID := enhanced
export ITCH_USERNAME := brianwo
export BUILD_CHANNEL := itch

run:
	flutter run -d linux

build-android:
	flutter build apk

build-web:
	flutter build web

build-linux:
	flutter build linux
	# Preparing AppImage
	cp -r build/linux/x64/release/bundle/ AppImage.AppDir
	cp docs/app_icon.png AppImage.AppDir/$(APP_NAME)_icon.png
	cp docs/appimage/AppImage.desktop AppImage.AppDir/
	cp docs/appimage/AppRun AppImage.AppDir/
	# Run appimagetool
	mkdir build/itch
	appimagetool AppImage.AppDir/ build/itch/enhanced.appimage
	# Remove evidence
	rm -r AppImage.AppDir

upload-itch: build/itch build/web
	# Linux build
	zip -r itch-linux.zip build/itch
	butler push "itch-linux.zip" "$(ITCH_USERNAME)/$(ITCH_GAME_ID):linux"
	# Web build
	zip -r itch-web build/web
	butler push "itch-web.zip" "$(ITCH_USERNAME)/$(ITCH_GAME_ID):web"
	

.PHONY: run
