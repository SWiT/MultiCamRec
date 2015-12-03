#!/bin/bash
clear

echo -e "MultiCamRec: Multiple Camera Recorder"

# Get arguments
while [[ $# > 0 ]]
do
key="$1"
case $key in
    -h|--help)
    DISPLAYHELP=1
    shift
    ;;
    -s|--startcam)
    STARTCAM="$2"
    shift
    ;;
    -n|--numcam)
    NUMCAM="$2"
    shift
    ;;
    -r|--resolution)
    RESOLUTION="$2"
    shift
    ;;
    -t|--time)
    DURATION="$2"
    shift
    ;;
    -c|--codec)
    CODEC="$2"
    shift
    ;;    
    *)
    # unknown option
    ;;
esac
shift # past argument or value
done


# Set default parameters if not set.
DISPLAYHELP=${DISPLAYHELP-0}
STARTCAM=${STARTCAM-0}
NUMCAM=${NUMCAM-1}
RESOLUTION=${RESOLUTION-1280x720}
DURATION=${DURATION-15}
CODEC=${CODEC-copy}

# Display help if requested.
if [ $DISPLAYHELP = 1 ]
then
    cat <<'_HELP'
Usage:
./multicamrec.sh [OPTIONS]

Options:
-s | --startcam [#]         The video index number of the first camera.
                            (ex. 2 for /dev/video2)
-n | --numcam [#]           The number of cameras to record from.
-t | --time [#]             The duration of the recordings in seconds.
-c | --codec [copy|h264]    The codec of the output video files
-r | --resolution [#x#]     The resolution of the cameras

Default Options:
startcam    0
numcam      1
time        15
codec       copy
resolution  1280x720

Example: Record 3 webcams starting with /dev/video1 for 60 seconds
./multicamrec.sh -s 1 -n 3 -t 60
_HELP
    exit 1
fi

# List the Cameras being used.
echo -e "Number of Cameras: $NUMCAM"
echo -e "Duration: $DURATION"
echo -e "Output Codec: $CODEC"
echo -e "Resolution: $RESOLUTION"


# Loop through each camera and launch the capture process.
((NUMCAM--))
ENDCAM=$((STARTCAM+NUMCAM))
for i in $(seq $STARTCAM $ENDCAM)
do
    echo "/dev/video$i"    
    COMMAND="avconv -f video4linux2 -input_format mjpeg -video_size $RESOLUTION -i /dev/video$i"
    if [ $CODEC = "h264" ]
    then
        COMMAND="$COMMAND -vcodec libx264 -preset ultrafast -threads 0 -t $DURATION -y cam_$i.mp4"
    else
        COMMAND="$COMMAND -c:v copy -t $DURATION -y cam_$i.mp4"
    fi
    echo -e "$COMMAND\n" > cam_$i.log
    $COMMAND 2>&1 &>> cam_$i.log &    
done


# Output Process IDs
ps | grep -E "(PID|avconv)"
echo

