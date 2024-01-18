# Select & Record

This is a simple bash script that allows users with a multi-monitor setup to 
record their screen.

## Features:
  - Detect connected monitors.
  - Select a monitor from list.
  - Launch a screen recording on the selected monitor.
  - Recording runs in the background.

**Dependencies:**  
  - ffmpeg
  - dmenu

## Usage

To start a recording, simply run: `./record.sh`

To stop a recording, run `/record.sh --stop` or `/record.sh -s`

You can also add the script to your '/usr/local/bin/' folder to access it via 
either the terminal or your launcher.

### Toggle Script 
I've also written an additional script that allows me to toggle the screen 
recording on/off. This is optional but mapping this script to a key is a very 
efficient way to start/stop recordings. 

```sh
#!/bin/bash

# Check if 'record' process is running
if pgrep -x "record" > /dev/null
then
    # If it is running, stop it
    record --stop
else
    # If it's not running, start it
    record
fi

```
