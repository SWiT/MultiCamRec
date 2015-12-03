# MultiCamRec: Multiple Camera Recorder
This bash script is meant for simultaneous launching multiple instances of avconvto record video from multiple USB webcams. The video sources must be consecutive (Ex. /dev/video1, /dev/video2, and /dev/video). Each video is saved as cam_#.mp3 with the terminal output of avconv saved as cam_#.log. This script has been tested on Ubuntu 14.04.3 LTS. It requires avconv which is part of the libav-tools package.

Requirements:
sudo apt-get install libav-tools

Example: Record 3 webcams starting with /dev/video1 for 60 seconds
```
./record.sh -s 1 -n 3 -t 60
```
Usage:
```
./multicamrec.sh [OPTIONS]
```
Options:
```
-s | --startcam [#]         The video index number of the first camera (ex. 2 for /dev/video2)
-n | --numcam [#]           The number of cameras to record from.
-t | --time [#]             The duration of the recordings in seconds.
-c | --codec [copy]         The codec of the output video files
-r | --resolution [#x#]     The resolution of the cameras
```
Default Options:
```
startcam    0
numcam      1
time        15
codec       copy
resolution  1280x720
```
