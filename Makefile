setup:
	brew bundle
	carthage bootstrap --cache-builds --platform iOS
	@echo " "
	@echo "\033[0;33m ▸ \033[0m\033[0;32mProject ready for testing / development, open ProntoSDK.xcodeproj\033[0m"

help:
	@echo "Available make commands:"
	@echo "   $$ make setup - install the dev project"