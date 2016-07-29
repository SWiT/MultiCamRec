import RPi.GPIO as GPIO
import time
import datetime
import subprocess
import os
import sys

GPIO.setwarnings(False) # This suppresses warning on repeat runs.

workingfolder = "/home/pi/MultiCamRec/"
picturefolder = "/home/pi/Pictures/"
videofolder = "/home/pi/Videos/"

GPIO.setmode(GPIO.BCM)  # Set board mode to Broadcom
pin_button = 23
pin_LED = 24

GPIO.setup(pin_button, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(pin_LED, GPIO.OUT)  

running = False
GPIO.output(pin_LED, running)  

proc = None

cameraid = 0 # Default camera id
cameramode = "PICTURE" # Default camera mode
blinkdelay = 2 # Default startup blink time
auto = 0 # Disable automatic button timer by default
lastpress = 0 # Time of the last button press

# Parse options and parameters.
for index, arg in enumerate(sys.argv):
    if arg == "--camera" or arg == "-c":
        cameraid = int(sys.argv[index+1])
    elif arg == "--delay" or arg == "-d":
        blinkdelay = int(sys.argv[index+1])
    elif arg == "--auto" or arg == "-a":
        auto = int(sys.argv[index+1])
    elif arg == "--video" or arg == "-v":
        cameramode = "VIDEO"
    elif arg == "--picture" or arg == "-p":
        cameramode = "PICTURE"
		
print("-------------")
print("MultiCamRec")
print("-------------")
print("CAMERA %s"%cameraid)
print("%s MODE"%cameramode)
if auto > 0:
    print("AUTO TIMER %s"%auto)

# Blink when the script starts.
for i in range(0, blinkdelay):
    GPIO.output(pin_LED, True)
    time.sleep(0.25)
    GPIO.output(pin_LED, False)
    time.sleep(0.25)
    GPIO.output(pin_LED, True)
    time.sleep(0.25)
    GPIO.output(pin_LED, False)
    time.sleep(0.25)
    
print("Ready")

extension = ".avi" if (cameramode == 'VIDEO') else ".jpg"

# Video mode
if cameramode == 'VIDEO':
    command = "avconv"
    command += " -f video4linux2"
    command += " -input_format mjpeg"
    command += " -s 1920x1080"
    command += " -r 30"
    command += " -i /dev/video0"
    command += " -c:v copy"
    command += " -t 29"
    command += " -y"
    command += " " + videofolder
# Picture mode    
else:
    command = "avconv"
    command += " -f video4linux2"
    command += " -s 1920x1080"
    command += " -i /dev/video0"
    command += " -ss 0:0:3" # Delay 3 seconds to allow the camera to reach full brightness.
    command += " -vframes 1"
    command += " -y"
    command += " " + picturefolder

while True:
    button_state = GPIO.input(pin_button)
    if auto > 0 and lastpress > 0 and (time.time() - lastpress) >= auto:
        lastpress = time.time()
        button_state = False
        
    if button_state == False:
        print('Button Pressed')
        lastpress = time.time()
        if not running:
            d = datetime.datetime.now();
            filename = d.strftime("%Y%m%d%H%M%S_CAM" + str(cameraid))
            outputfile = filename + extension
            # Create the log file.
            if cameramode == 'VIDEO':
                logfile = videofolder + filename + ".log"
            else:
                logfile = picturefolder + filename + ".log"
            log = open(logfile, "a")
            c = command + outputfile
            log.write(c + '\n\n')
            log.flush()
            print c
            proc = subprocess.Popen(c, shell=True, stdout=log, stderr=log)
            running = True
        else:
            if proc != None:
                proc.poll()
                if (proc.returncode == None):
                    print("Terminating process")
                    proc.kill()
                print("Returncode: %s"%proc.returncode)
            else:
                print("No process")
            running = False
        GPIO.output(pin_LED, running)
        time.sleep(1.0)

    if proc != None and running:
        proc.poll()
        if (proc.returncode != None):
            print("Returncode: %s"%proc.returncode)
            running = False
            GPIO.output(pin_LED, running)
            
    time.sleep(0.1)
