#!/bin/bash

exit 1

FR=24

#Ok here are the orig commands
#ffmpeg -f x11grab -r 15 -s 1920x1080 -i :0.0+1920,0 -vcodec libx264 -preset ultrafast slides.mkv
#ffmpeg -f x11grab -r 15 -s 1920x1080 -i :0.0+0,0 -vcodec libx264 -preset ultrafast terminal.mkv
#ffmpeg -f pulse -i default -f v4l2 -framerate 30 -input_format h264 -video_size hd1080 -i /dev/video0 -preset ultrafast -c copy talking_head.mkv

capture_slides() {
  local output_dir=$1
  local duration=$2
  ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f x11grab -r ${FR} -s hd1080 -i :0.0+1920,0 \
    -vcodec libx264 \
    -preset ultrafast \
    $output_dir/slides.mkv > $output_dir/slides.log 2>&1
  echo "slides done"
}

capture_terminal() {
  local output_dir=$1
  local duration=$2
  ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f x11grab -r ${FR} -s hd1080 -i :0.0+0,0 \
    -vcodec libx264 \
    -preset ultrafast \
    $output_dir/terminal.mkv > $output_dir/terminal.log 2>&1
  echo "terminal done"
}

capture_webcam() {
  local output_dir=$1
  local duration=$2
    #-preset ultrafast \
    #-f pulse -i default \
    #-f alsa -i pulse \
    #-r 15 \
  ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f pulse -i default \
    -f v4l2 -framerate ${FR} -input_format h264 -video_size hd1080 -i /dev/video0 \
    -c copy \
    $output_dir/webcam.mkv > $output_dir/webcam.log 2>&1
  echo "webcam done"
}

TS=`date +%Y%m%d%H%M`

OUTPUT_DIR="capture-$TS"

mkdir -p $OUTPUT_DIR

echo "starting run at $TS"

echo "capturing slides"
capture_slides $OUTPUT_DIR &

echo "capturing terminal"
capture_terminal $OUTPUT_DIR &

echo "capturing webcam"
capture_webcam $OUTPUT_DIR &

for job in `jobs -p`; do
  wait $job
done

echo "done with primary captures"

echo "done"

