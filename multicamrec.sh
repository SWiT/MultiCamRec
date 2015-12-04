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
    -if|--inputformat)
    INPUTFORMAT="$2"
    shift
    ;;
    -of|--outputformat)
    OUTPUTFORMAT="$2"
    shift
    ;;
    -fps|--framespersecond)
    FPS="$2"
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
INPUTFORMAT=${INPUTFORMAT-mjpeg}
OUTPUTFORMAT=${OUTPUTFORMAT-copy}
FPS=${FPS-30}

# Display help if requested.
if [ $DISPLAYHELP = 1 ]
then
    cat <<'_HELP'
Usage:
./multicamrec.sh [OPTIONS]

Options:
-s | --startcam [#]     id number of the first camera (ex. 2 for /dev/video2)
-n | --numcam [#]       number of cameras to record from
-t | --time [#]         duration of the recordings in seconds
-r | --resolution [#x#]     resolution of the cameras
-fps | --framespersecond    limit the frames per second of the cameras
-if | --inputformat [raw|mjpeg]     format of the input cameras
-of | --outputformat [copy|h264]    format of the output video files

Default Options:
startcam        0
numcam          1
time            15
resolution      1280x720
fps             30
inputformat     mjpeg
outputformat    copy

Example: Record 3 webcams starting with /dev/video1 for 60 seconds
./multicamrec.sh -s 1 -n 3 -t 60
_HELP
    exit 1
fi

# List the Cameras being used.
echo -e "Number of Cameras: $NUMCAM"
echo -e "Duration: $DURATION"
echo -e "Input FPS: $FPS"
echo -e "Input Format: $INPUTFORMAT"
echo -e "Output Format: $OUTPUTFORMAT"
echo -e "Resolution: $RESOLUTION"


# Loop through each camera and launch the capture process.
((NUMCAM--))
ENDCAM=$((STARTCAM+NUMCAM))
for i in $(seq $STARTCAM $ENDCAM)
do
    echo "/dev/video$i"

    # The command
    COMMAND="avconv"

    # The input
    if [ $INPUTFORMAT = "raw" ]
    then
        # Raw camera input. Warning: 1280x720x24x30/1000000 = 663Mbps. You can't get 30fps on a USB 2.0 camera. 21.7fps max in theory.
        COMMAND="$COMMAND -f video4linux2 -s $RESOLUTION -r $FPS -i /dev/video$i"
        EXTENSION="avi"
    else
        # MJPEG (default) it's the widest used compression
        COMMAND="$COMMAND -f video4linux2 -input_format mjpeg -video_size $RESOLUTION -r $FPS -i /dev/video$i"
        EXTENSION="mp4"
    fi
    
    # The output
    if [ $OUTPUTFORMAT = "h264" ]
    then
        # h264
        COMMAND="$COMMAND -vcodec libx264 -preset ultrafast -threads 0 -t $DURATION -y cam_$i.mp4"
    else
        # copy (default)
        COMMAND="$COMMAND -c:v copy -t $DURATION -y cam_$i.$EXTENSION"
    fi

    # Insert the command as the first line of the log file.
    echo -e "$COMMAND\n" > cam_$i.log

    # Launch the command, log the output, and detach process.
    $COMMAND 2>&1 &>> cam_$i.log &
done

# Output Process IDs
ps | grep -E "(PID|avconv)"
echo

