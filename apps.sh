#!/usr/bin/env bash

hash mas 2>/dev/null || { echo >&2 "'mas' not found, install via 'brew install mas'."; exit 1; }

# Install the apps from app store
declare -A apps
apps["904280696"]="Things"
apps["405399194"]="Kindle"
apps["425424353"]="The Unarchiver"
apps["494803304"]="WiFi Explorer"
apps["937984704"]="Amphetamine"
apps["1262957439"]="Textual IRC Client"
apps["1153157709"]="Speedtest"
apps["409203825"]="Numbers"
apps["497799835"]="Xcode"
apps["413965349"]="Soulver"
apps["408981434"]="iMovie"
apps["1091189122"]="Bear"
apps["1176895641"]="Spark"
apps["924726344"]="Deliveries"
apps["419330170"]="Moom"

mas install "${!apps[@]}"
