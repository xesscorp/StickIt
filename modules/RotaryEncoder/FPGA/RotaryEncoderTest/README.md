Rotary Encoder Test Design
======================================================

This FPGA design displays the accumulator of the
StickIt! Rotary Encoder module on a PC connected to the
XuLA + StickIt! + StickIt! Rotary Encoder board combination.


Important Files
-----------------------------------------------------

`RotaryEncoderTest.vhd`: Module that reads the rotary encoder accumulator and 
    sends it back to the PC through a HostIoToDut module.

`RotaryEncoderTest.ucf`: Pin assignments for connecting the XuLA FPGA
   board to the StickIt! Rotary Encoder module via the StickIt! motherboard.
   (If you are using a XuLA2 board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file.
   The [`xulate`](https://github.com/xesscorp/xulate) program will help you do that.)

`RotaryEncoderTest.xise`: The Xilinx ISE project file that ties all the previous files together.

`rot_enc_test.py`: A Python file that establishes communication with the XuLA board
   and repeatedly displays the rotary encoder accumulator value as a hexadecimal number.
   (Use `pip install xstools` or `easy_install xstools` to install the Python
   packages that will make this program work.)


   Running the Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
2. Insert a XuLA board into a StickIt! motherboard.
3. Attach a StickIt! Rotary Encoder module to the PM2 connector of the motherboard.
4. (Optional) Attach a StickIt! LED Digits module to the WING2 connector of the motherboard.
5. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
5. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
6. Run the command `python rot_enc_test.py` to start the polling of the rotary encoder.
   The accumulator value will be displayed as a hexadecimal number on the PC and the
   LED digits.

