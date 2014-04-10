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
   
import sys
import math
import random
import struct
from pprint import pprint
from xstools.xsi2c import *  # Import funcs/classes for PC <=> FPGA <=> I2C link.

print '''\n
##################################################################
# This program tests the interface between the host PC and the FPGA 
# on the XuLA board that has been programmed to interface to the
# InvenSense MPU-6050.
##################################################################
'''

USB_ID = 0  # This is the USB index for the XuLA board connected to the host PC.
I2C_ID = 0xff
MPU_I2C_ADDRESS = 0x68
# Create an interface object that talks to the I2C interface in the FPGA that connects to the MPU.
mpu = XsI2c(xsusb_id=USB_ID, module_id=I2C_ID, i2c_address=MPU_I2C_ADDRESS)

# Let's check the "Who am I?" register to make sure it has the correct value.
MPU_WHO_AM_I = 0x75 # Register adddress.
who_am_i_value = mpu.rd_reg(MPU_WHO_AM_I)[0]
assert who_am_i_value == 0x68

# Now, take the chip out of sleep mode.
MPU_PWR_MGMT_1 = 0x6B
mpu.wr_reg(MPU_PWR_MGMT_1, [0])

# Use the lowest bandwidth low-pass filtering on the accelerometer and gyroscope readings.
MPU_CFG = 0x1A
mpu.wr_reg(MPU_CFG, [6])

MPU_ACCEL_XOUT_H = 0x3B # Accelerometer, temp sensor and gyroscope registers start at this address.

# Read the 14 bytes of raw AccelX, AccelY, AccelZ, Temperature, GyroX, GyroY, GyroZ sensor data.
accel_temp_gyro = ''.join([chr(b) for b in mpu.rd_reg(MPU_ACCEL_XOUT_H, 14)])

# Unpack the 14 bytes into seven 16-bit signed integers.
(accel_x, accel_y, accel_z, temp, gyro_x, gyro_y, gyro_z) = struct.unpack('>7h', accel_temp_gyro)

# Convert the raw temperature reading into Farenheit and Celsius.
print 'Temperature (F) = %f' % ((36.53 + temp/340.0) * 1.8 + 32.0)
print 'Temperature (C) = %f' % (36.53 + temp/340.0)

# Continually read the sensors and display their raw 16-bit hex values.
print "\n Accelerometer  Temp   Gyroscope"
print "  X    Y    Z    T    X    Y    Z"
avg_data = [0,0,0,0,0,0,0]
while True:
    accel_temp_gyro = ''.join([chr(b) for b in mpu.rd_reg(MPU_ACCEL_XOUT_H, 14)])
    raw_data = struct.unpack('>7H', accel_temp_gyro)
    raw_signed_data = struct.unpack('>7h', accel_temp_gyro)
    avg_data = [0.9*x+0.1*y for x,y in zip(avg_data, raw_signed_data)]
    total_accel = math.sqrt(sum(x*x for x in avg_data[:3]))
    avg_data.append(total_accel)
    print '%04x %04x %04x %04x %04x %04x %04x %04x\r' % tuple(avg_data),

sys.exit(0)
