import RPi.GPIO as GPIO
import time
import datetime
import subprocess
import os

GPIO.setwarnings(False) # This suppresses warning on repeat runs.

GPIO.setmode(GPIO.BCM)  # Set board mode to Broadcom
pin_button = 23
pin_LED = 24

GPIO.setup(pin_button, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(pin_LED, GPIO.OUT)  

running = False
GPIO.output(pin_LED, running)  

proc = None

# Get the Camera ID.
cameraid = -1
for i in range(0,8):
    filename = "/home/pi/MultiCamRec/CAMERA_" + str(i)
    if os.path.isfile(filename):
        cameraid = i
        break

print("-------------")
print("MultiCamRec")
print("-------------")
print("CAMERA_%s"%cameraid)

# Blink when the script starts.
for i in range(0,10):
    GPIO.output(pin_LED, True)
    time.sleep(0.25)
    GPIO.output(pin_LED, False)
    time.sleep(0.25)
print("Ready")

command = "avconv"
command += " -f video4linux2"
command += " -input_format mjpeg"
command += " -video_size 1920x1080"
command += " -r 30"
command += " -i /dev/video0"
command += " -c:v copy"
command += " -t 60"
command += " -y"
command += " /home/pi/MultiCamRec/"
#command += "video0.mp4"

while True:
    button_state = GPIO.input(pin_button)
    if button_state == False:
        print('Button Pressed')
        if not running:
            d = datetime.datetime.now();
            filename = d.strftime("%Y%m%d%H%M%S_CAM" + str(cameraid) + ".mp4")
            print command+filename
            proc = subprocess.Popen(command+filename, shell=True)
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

    if proc != None and running:
        proc.poll()
        if (proc.returncode != None):
            print("Returncode: %s"%proc.returncode)
            running = False
            GPIO.output(pin_LED, running)
            
    time.sleep(0.2)
