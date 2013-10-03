DIP Switch Test Design
======================================================

This FPGA design displays the switch settings of the
StickIt! DIP Switch module on a PC connected to the
XuLA + StickIt! + StickIt! DIPSwitch board combination.


Important Files
-----------------------------------------------------

`DipswTest.vhd`: Module that reads the switch state and sends it back to
    the PC through a HostIoToDut module.

`DipswTest.ucf`: Pin assignments for connecting the XuLA FPGA
   board to the StickIt! DIPSwitch module via the StickIt! motherboard.
   (If you are using a XuLA2 board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file.
   The [`xulate`](https://github.com/xesscorp/xulate) program will help you do that.)

`DipswTest.xise`: The Xilinx ISE project file that ties all the previous files together.

`dipsw_test.py`: A Python file that establishes communication with the XuLA board
   and repeatedly displays the DIP switch settings as a hexadecimal number.
   (Use `pip install xstools` or `easy_install xstools` to install the Python
   packages that will make this program work.)


   Running the Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
2. Insert a XuLA board into a StickIt! motherboard.
3. Attach a StickIt! DIPSwitch module to the WING3 connector of the motherboard.
4. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
5. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
6. Run the command `python dipsw_test.py` to start the polling of the DIP switches.
   The DIP switch settings will be displayed on the PC as a hexadecimal number.

