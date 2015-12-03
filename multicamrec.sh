#!/bin/bash
clear

# Get arguments
while [[ $# > 1 ]]
do
key="$1"
case $key in
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
STARTCAM=${STARTCAM-0}
NUMCAM=${NUMCAM-1}
RESOLUTION=${RESOLUTION-1280x720}
DURATION=${DURATION-15}
CODEC=${CODEC-copy}


# List the Cameras being used.
echo -e "MultiCamRec: Multiple Camera Recorder"
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
    if [ $CODEC = "h264" ]
    then
        avconv -f video4linux2 -input_format mjpeg -video_size $RESOLUTION -i /dev/video$i -vcodec libx264 -preset ultrafast -threads 0 -t $DURATION -y cam_$i.mp4 2>&1 &> cam_$i.log &
    else
        avconv -f video4linux2 -input_format mjpeg -video_size $RESOLUTION -i /dev/video$i -c:v copy -t $DURATION -y cam_$i.mp4 2>&1 &> cam_$i.log &
    fi

    # TODO: abstract the command, start the log files with a copy of the command.
	#COMMAND="avconv -f video4linux2 -input_format mjpeg -video_size $RESOLUTION -i /dev/video$i -c:v copy -t $DURATION -y cam_$i.mp4 2>&1 &> cam_$i.log"
    #echo $COMMAND
done


# Output Process IDs
ps | grep -v -E "(ps|grep|bash|multicamrec)"
echo

