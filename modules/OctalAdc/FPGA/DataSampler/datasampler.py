from xstools.xsmemio import *
from xstools.xsdutio import *
import matplotlib.pyplot as plt
import numpy as np

USB_ID = 0
RAM_ID = 255
ADC_ID = 254

# Create an object for reading the samples stored in SDRAM.
ram = XsMemIo(xsusb_id=USB_ID, module_id=RAM_ID)
# Create an object for controlling and monitoring the ADC.
adc = XsDutIo(xsusb_id=USB_ID, module_id=ADC_ID, dut_output_widths=[1, 1], dut_input_widths=[1])

adc.write(1)  # Enable sampling with the ADC.
while adc.read()[1].unsigned == 0:  # Wait until the ADC raises it's done signal indicating end of sampling.
    pass
adc.write(0)  # Lower the sampling enable signal.

NUM_SAMPLES = 9999   # Number of samples to upload from SDRAM.
SAMPLE_RATE = 1e6  # ADC sample rate in Hz.
samples = ram.read(0, NUM_SAMPLES)  # Read samples from the SDRAM, starting at address 0.
times = [i / SAMPLE_RATE for i in range(0, NUM_SAMPLES)]  # These are the times each sample was taken.


def adc_scale(sample):  # Scale the ADC sample value into a voltage.
    MAX_VOLTAGE = 5.0  # Voltage range of samples.
    MIN_VOLTAGE = 0.0
    NUM_ADC_BITS = 12  # ADC resolution.
    return sample * (MAX_VOLTAGE-MIN_VOLTAGE) / 2 ** NUM_ADC_BITS

# Get the samples and times for the red VGA signal at addresses 0, 3, 6, 9 ...
sine_red_v = [adc_scale(s.unsigned) for s in samples[0::3]]
sine_red_t = [t for t in times[0::3]]
# Get the samples and times for the green VGA signal at addresses 1, 4, 7, 10 ...
sine_grn_v = [adc_scale(s.unsigned) for s in samples[1::3]]
sine_grn_t = [t for t in times[1::3]]
# Get the samples and times for the blue VGA signal at addresses 2, 5, 8, 11 ...
sine_blu_v = [adc_scale(s.unsigned) for s in samples[2::3]]
sine_blu_t = [t for t in times[2::3]]

# Display the R, G and B signals as a graph.
plt.plot(sine_red_t, sine_red_v, color='red', label='VGA - Red')
plt.plot(sine_grn_t, sine_grn_v, color='green', label='VGA - Green')
plt.plot(sine_blu_t, sine_blu_v, color='blue', label='VGA - Blue')
plt.legend(loc='upper right')
plt.show()
