MPU-6050 Test Design
======================================================

This FPGA design displays the accelerometer, gyroscope and
temperature readings from a MPU-6050 chip on a PC connected to the
XuLA2 + StickIt! + StickIt! MPU-6050 board combination.


Important Files
-----------------------------------------------------

`MPUTest.vhd`: Master module that reads the MPU-6050 sensors and
   reports them back to the PC.
   
`HostIoToI2c.vhd`: Module that allows commands and data to flow
   between the PC's USB port and the I2C port of the MPU-6050 via the FPGA.
   
`I2c.vhd`: Master-mode I2C interface from OpenCores.org.

`MPUTest-XuLA2.ucf`: Pin assignments for connecting the XuLA2 FPGA
   board to the StickIt! DIPSwitch module via the StickIt! motherboard.
   (If you are using a XuLA board, then use the `MPUTest-XuLA.ucf` file, instead.)

`MPUTest.xise`: The Xilinx ISE project file that ties all the previous files together.

`MPUTest.py`: A Python file that establishes communication with the XuLA board
   and repeatedly reads and displays the MPU-6050 sensors as hexadecimal numbers.
   (Use `pip install xstools` or `easy_install xstools` to install the Python
   packages that will make this program work.)


   Running the Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
2. Insert a XuLA2 board into a StickIt! motherboard.
3. Attach a StickIt! MPU-6050 module to the PM6 connector of the motherboard.
4. Attach a USB cable to the XuLA2 board. (This will supply power for the
   entire collection of boards and modules.)
5. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
6. Run the command `python MPUTest.py` to start the polling of the MPU-6050.
   The sensor readings will be displayed on the PC as hexadecimal numbers.

