LED Digits Test Design
======================================================

This FPGA design displays some scrolling text on the 
StickIt! LED Digits module.


Important Files
-----------------------------------------------------

`LedDigits.vhd`: Module for driving the StickIt! LED Digits module so it can 
    display numbers and letters. It also contains the test module.

`Common.vhd`: Commonly-used definitions and functions.
	
`LedDigitsTest.ucf`: Pin assignments for connecting the XuLA FPGA
	board to the StickIt! LED Digits module via the StickIt! motherboard.
   (If you are using a XuLA2 board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file.
   The [`xulate`](https://github.com/xesscorp/xulate) program will help you do that.)

`LedDigitsTest.xise`: The Xilinx ISE project file that ties all the previous files together.

	
Running the LED Digits Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
1. Insert a XuLA board into a StickIt! motherboard.
1. Attach a StickIt! LED Digits module to the WING3 connector of the motherboard.
1. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
1. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
   After the download completes, a series of characters should scroll from right-to-left across the
   LED digits.

