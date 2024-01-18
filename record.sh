#!/bin/bash

# Function to prompt the user to select a monitor using dmenu
select_monitor() {
  # Get a list of monitors, exclude the header line, and use dmenu for user selection
  MONITORS=$(xrandr --listmonitors | grep -v "Monitors" | awk '{print $4}')
  SELECTED_MONITOR=$(echo "$MONITORS" | dmenu -l 5 -p "Select Monitor:")

  # Check if a monitor was selected or if the selection was cancelled
  if [ -n "$SELECTED_MONITOR" ]; then
      echo "$SELECTED_MONITOR"
  else
      echo "Cancelled"
  fi
}

# Function to start the recording on the specified monitor
start_recording() {
  MONITOR=$1

  # If the selection was cancelled, exit the script
  if [ "$MONITOR" == "Cancelled" ]; then
      exit
  fi

  # Get screen resolution and coordinates for the selected monitor
  MONITOR_OPT=$(xrandr --listmonitors | grep "$MONITOR")
  COORDINATES=$(echo "$MONITOR_OPT" | awk -F'+' '{print $(NF-1) "+" $NF}' | awk '{print $1}' | sed 's/+/,/g')
  INRES=$(echo "$MONITOR_OPT" | grep -oP '\b\d+/\d+x\d+\b' | sed 's,/[^x]*x,x,')
  
  # Set up file name, frame rate, and other options for ffmpeg
  # We can choose the format in dmenu
  # ffmpeg input for "mkv" is matroska, so we adjust.
  EXTENSION=$(echo -e "mp4\nmkv" | dmenu -p "Choose Format:")
  if [[ "$EXTENSION" == mkv ]]; then
    FORMAT="matroska"
  else
    FORMAT="mp4"
  fi

  FPS="60"
  FILE_NAME="output_$(date +"%Y%m%d_%H%M%S").$EXTENSION"

  # Run ffmpeg to start recording on the specified monitor
  # echo "$FILE_NAME $FORMAT $FPS $INRES $COORDINATES"

  ffmpeg -f x11grab -probesize 42M -s "$INRES" -r "$FPS" -i :0.0+"$COORDINATES" -f alsa -ac 2 \
  -i default -vcodec libx264 \
  -acodec aac -ab 192k -ar 44100 \
  -threads 0 -f $FORMAT "$FILE_NAME"
}

# Function to stop the recording gracefully
stop_recording() {
  # Send an interrupt signal to the ffmpeg process to stop the recording gracefully
  pkill -INT -f "ffmpeg -f x11grab"
}

# Function to present a menu for selecting actions (select monitor, start recording, etc.)
record_menu() {
  # Check if the script is called with --stop or -s option
  if [ "$1" == "--stop" ] || [ "$1" == "-s" ]; then
      # If stop option is given, call stop_recording function and exit
      stop_recording
      exit
  fi

  # Prompt the user to choose an action using dmenu
  ACTION=$(echo -e "Select Monitor & Start Recording" | dmenu -p "Choose Action:")

  # Evaluate the user's choice
  case "$ACTION" in
      "Select Monitor & Start Recording")
          # If the user chooses to select a monitor, call select_monitor function
          SELECTED_MONITOR=$(select_monitor)
          # Start recording on the selected monitor
          start_recording "$SELECTED_MONITOR"
          ;;
      *)
          # If the user cancels or chooses an unrecognized option, print "Cancelled"
          echo "Cancelled"
          ;;
  esac
}

# Call the record_menu function and pass any command-line arguments received by the script
record_menu "$@"

