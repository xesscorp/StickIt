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
# on the XuLA board that has been programmed to scan a dip switch.
# You should see the state of the switches displayed on the screen.
##################################################################
'''
USB_ID = 0  # This is the USB port index for the XuLA board connected to the host PC.
DIPSW_ID = 255  # This is the identifier for the dip switch interface in the FPGA.

# Create an interface object that takes eight 1-bit inputs and has one 1-bit output.
dipsw = XsDutIo(USB_ID, DIPSW_ID, [8], [1])

while True: # Do this forever...
    dipsw_state = dipsw.Read() # Read the current state of the dip switches.
    print 'DIP Switch State: %2x\r' % dipsw_state.unsigned, # Print the dip switch state and return.
