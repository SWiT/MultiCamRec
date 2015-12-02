#!/bin/bash

clear

# Get arguments
while [[ $# > 1 ]]
do
key="$1"
case $key in
    -n|--numcam)
    NUMCAM="$2"
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
NUMCAM=${NUMCAM-1}
DURATION=${DURATION-20}
CODEC=${CODEC-mjpeg}

# List the Cameras being used.
echo -e "Number of Cameras: $NUMCAM"
echo -e "Duration: $DURATION"
echo -e "Output Codec: $CODEC"

# Loop through each camera and launch the capture process.
((NUMCAM--))
for i in $(seq 0 $NUMCAM)
do
	echo "/dev/video$i"
	avconv -f video4linux2 -input_format mjpeg -video_size 1280x720 -i /dev/video$i -c:v copy -t $DURATION -y cam_$i.mp4 2>&1 &> cam_$i.log &

	# Use h264 to shrink output filesize.
	#avconv -f video4linux2 -input_format mjpeg -video_size 1280x720 -i /dev/video0 -vcodec libx264 -preset ultrafast -threads 0 -t 60 -y cam_0.mp4 2>&1 &> cam_0.log &
done

echo -e "RECORDINGS LAUNCHED.\n"
