# import sys
# sys.path.insert(0, r'C:\xesscorp\products\xstools')

from xstools.xsmemio import *
from xstools.xsdutio import *
import matplotlib.pyplot as plt

USB_ID = 0
RAM_ID = 255
CTRL_ID = 254

# Create an object for reading the samples stored in SDRAM.
ram = XsMemIo(xsusb_id=USB_ID, module_id=RAM_ID)
# Create an object for controlling and monitoring the codec sampling.
ctrl = XsDutIo(xsusb_id=USB_ID, module_id=CTRL_ID, dut_output_widths=[1, 1], dut_input_widths=[1, 1])

while True:
    ctrl.write(0,0)
    raw_input('Press Enter to start recording')
    ctrl.write(1,0)
    raw_input('Press Enter to stop recording')
    ctrl.write(0,0)
    raw_input('Press Enter to start playback')
    ctrl.write(0,1)
    ctrl.write(1,1)
    raw_input('Press Enter to stop playback')
    ctrl.write(0,0)
