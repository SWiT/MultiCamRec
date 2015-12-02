#!/bin/bash

clear

#avconv -f video4linux2 -b 230M -r 30 -s 640x480 -pix_fmt yuv422p -i /dev/video0 -vcodec libx264 -t 10 -y cam_0.avi 2>&1 &> cam_0.log &
#avconv -f video4linux2 -b 230M -r 30 -s 640x480 -pix_fmt yuv422p -i /dev/video1 -vcodec libx264 -t 10 -y cam_1.avi 2>&1 &> cam_1.log &

avconv -f video4linux2 -input_format mjpeg -video_size 1280x720 -i /dev/video0 -c:v copy -t 15 -y cam_0.mp4 2>&1 &> cam_0.log &

#Cut the output size in half with h264.
#avconv -f video4linux2 -input_format mjpeg -video_size 1280x720 -i /dev/video0 -vcodec libx264 -preset ultrafast -threads 0 -t 15 -y cam_0.mp4 2>&1 &> cam_0.log &


#Ryan's Suggestion:
#avconv -f video4linux2 -input_format mjpeg -video_size 1280x720 -i /dev/video0 -c:v copy video0.mp4 > /dev/null 2>&1 < /dev/null &
#avconv -f video4linux2 -input_format mjpeg -video_size 1280x720 -i /dev/video1 -c:v copy video1.mp4 > /dev/null 2>&1 < /dev/null &

echo -e "\nRECORDINGS LAUNCHED.\n"
