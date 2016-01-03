# MultiCamRec: Multiple Camera Recorder
The goal of this project is to simultaneously record from multiple USB cameras.

## Python Script
The Python script is meant for launching avconv simultaneously on multiple Raspberry Pi Zeros with a single button press. There is a status LED for each RPi0.  The LED blinks on startup for 30 seconds. After that a button press will launch avconv and turn on the status LED for as long as the process runs. A second button press while the process is still running should kill the process. I have found killing the process may lock up the camera and require a reboot.

Setup:
```
# From the default pi users home folder on each RPi
git clone https://github.com/SWiT/MultiCamRec.git
crontab -e
# Add the following line 
@reboot python /home/pi/MultiCamRec/rpi_button.py
```

Wiring:
```
# TODO: a wiring diagram
Pin 16, GPIO23, is the button signal.
Pin 17, 3.3V, from one of the RPis goes to the button's pull up resistor.
Pin 18, GPIO24, is the status LED.
Pin 20, GND, is connected together on each RPi.
```


## Bash Script
The bash script simultaneously launches multiple instances of avconv to record video from multiple USB webcams connected to a single Linux PC. You will need to have each camera connected to a separate USB host controller. Even when using MJPEG compression there isn't enough bandwidth at 720p or 1080p on most controllers for more than one USB camera at a time. The video sources must be consecutive (Ex. /dev/video0, /dev/video1, and /dev/video2). Each video is saved as cam_#.mp4 with the terminal output of avconv saved as cam_#.log. This script has been tested on Ubuntu 14.04.3 LTS. It requires avconv which is part of the libav-tools package. 

Requirements:
sudo apt-get install libav-tools

Example: Record 3 webcams starting with /dev/video1 for 60 seconds
```
./multicamrec.sh -s 1 -n 3 -t 60
```
Usage:
```
./multicamrec.sh [OPTIONS]
```
Options:
```
-s | --startcam [#]     id number of the first camera (ex. 2 for /dev/video2)
-n | --numcam [#]       number of cameras to record from
-t | --time [#]         duration of the recordings in seconds
-r | --resolution [#x#]     resolution of the cameras
-fps | --framespersecond    limit the frames per second of the cameras
-if | --inputformat [raw|mjpeg]     format of the input cameras
-of | --outputformat [copy|h264]    format of the output video files
```
Default Options:
```
startcam        0
numcam          1
time            15
inputformat     mjpeg
outputformat    copy
resolution      1280x720
```
