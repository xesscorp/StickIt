# /***********************************************************************************
# *   This program is free software; you can redistribute it and/or
# *   modify it under the terms of the GNU General Public License
# *   as published by the Free Software Foundation; either version 2
# *   of the License, or (at your option) any later version.
# *
# *   This program is distributed in the hope that it will be useful,
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# *   GNU General Public License for more details.
# *
# *   You should have received a copy of the GNU General Public License
# *   along with this program; if not, write to the Free Software
# *   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# *   02111-1307, USA.
# *
# *   (c)2013 - X Engineering Software Systems Corp. (www.xess.com)
# ***********************************************************************************/

from xstools.xsdutio import *  # Import funcs/classes for PC <=> FPGA link.

print '''\n
##################################################################
# This program tests the interface between the host PC and the FPGA 
# on the XuLA board that has been programmed to scan a rotary encoder.
# You should see the state of the rotary encoder accumulator
# displayed on the screen.
##################################################################
'''
USB_ID = 0  # This is the USB port index for the XuLA board connected to the host PC.
ROTENC_ID = 255  # This is the identifier for the rotary encoder interface in the FPGA.

# Create an interface object that reads one 32-bit output from the rotary encoder module and
# drives one 1-bit dummy-input to the rotary encoder module.
rotenc = XsDutIo(xsusb_id=USB_ID, module_id=ROTENC_ID, dut_output_widths=[32], dut_input_widths=[1])

while True: # Do this forever...
    accumulator = rotenc.Read() # Read the current state of the dip switches.
    print 'Rotary encoder accumulator: %8x\r' % accumulator.unsigned, # Print the dip switch state and return.
