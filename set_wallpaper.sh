#!/usr/bin/env bash

osascript <<EOF
tell application "System Events"
    repeat with d in every desktop
        set picture of d to "/System/Library/Desktop Pictures/Big Sur Coastline.madesktop"
    end repeat
end tell
EOF
