import RPi.GPIO as GPIO
import time
import subprocess

GPIO.setwarnings(False) # This suppresses warning on repeat runs.

GPIO.setmode(GPIO.BCM)  # Set board mode to Broadcom

pin_button = 23
pin_LED = 24

GPIO.setup(pin_button, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(pin_LED, GPIO.OUT)  


buttonstate = False
GPIO.output(pin_LED, buttonstate)  

proc = None

print("-------------");
print("MultiCamRec")
print("-------------");
while True:
    input_state = GPIO.input(pin_button)
    if input_state == False:
        print('Button Pressed')
        buttonstate = not buttonstate
        GPIO.output(pin_LED, buttonstate)

        print(subprocess.check_output("ls -la", shell=True))
        #proc = subprocess.Popen("multicamrec.sh", shell=True)

    if proc != None:
        proc.poll()
        #print proc.returncode
        
    time.sleep(0.2)
