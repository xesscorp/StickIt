from xstools.xsmemio import *
from xstools.xsdutio import *
import matplotlib.pyplot as plt

USB_ID = 0
RAM_ID = 255
CTRL_ID = 254

# Create an object for reading the samples stored in SDRAM.
ram = XsMemIo(xsusb_id=USB_ID, module_id=RAM_ID)
# Create an object for controlling and monitoring the codec sampling.
ctrl = XsDutIo(xsusb_id=USB_ID, module_id=CTRL_ID, dut_output_widths=[1, 1], dut_input_widths=[1])

NUM_SAMPLES = 10000   # Number of samples to upload from SDRAM.
SAMPLE_RATE = 48000.0  # ADC sample rate in Hz.

# Generator function for creating sine waves.
def test_sine(freq, amplitude, offset):
  import math as m
  t_step = 1/SAMPLE_RATE
  i = 0
  while True:
    yield(int(amplitude * m.sin(2.0*m.pi*freq*i*t_step) + offset))
    i = i+1

# Generate the sine wave for the left stereo output channel.
sine1 = test_sine(2000.0, 10000.0, 0.0)
test_wave_left  = [sine1.next() for i in range(0, NUM_SAMPLES)]
# Generate the sine wave for the right stereo output channel.
sine2 = test_sine(1000.0, 5000.0, 0.0)
test_wave_right = [sine2.next() for i in range(0, NUM_SAMPLES)]
# Interleave the left and right sine wave values.
test_waves = [x for t in zip(test_wave_left, test_wave_right) for x in t]
# Upload the sine wave values to the SDRAM on the XuLA2 board.
ram.write(20000, test_waves, data_type=-1)

ctrl.write(1)  # Enable codec sampling/output.
while ctrl.read()[1].unsigned == 0:  # Wait until the codec raises it's done signal indicating end of sampling.
    pass
ctrl.write(0)  # Lower the enable signal.

sampled_waves = ram.read(0, 2*NUM_SAMPLES)  # Read left/right-channel samples from the SDRAM, starting at address 0.
sampled_waves = [-s.integer for s in sampled_waves] # Correct for the inversion of the output by the AudioIO output opamp.
sampled_wave_left = sampled_waves[0::2] # Left input samples are at even-numbered addresses.
sampled_wave_right = sampled_waves[1::2] # Right input samples are at odd-numbered addresses.
times = [i / SAMPLE_RATE for i in range(0, NUM_SAMPLES)]  # These are the times each sample was taken.

# Display the generated sine waves and the sampled input waves.
shift = 34 # Shift the input samples by this much to make them line up with the generated sine waves.
plt.plot(times, test_wave_left, color='magenta', label='Left-Out')
plt.plot(times[:-shift], sampled_wave_left[shift:], color='green', label='Left-In')
plt.plot(times, test_wave_right, color='cyan', label='Right-Out')
plt.plot(times[:-shift], sampled_wave_right[shift:], color='red', label='Right-In')
plt.legend(loc='upper right')
plt.show()
