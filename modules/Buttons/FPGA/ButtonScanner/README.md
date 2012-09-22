Button Scanner Test Design
======================================================

This FPGA design scans the StickIt! Buttons module and displays
the hexadecimal number of a pressed button (1, 2, 3, ..., A, B, C)
on the first digit of the StickIt! LED module.


Important Files
-----------------------------------------------------

`ButtonScanner.vhd`: Module for scanning the StickIt! Button module.
	It also contains the test module.
	
`LedDigits.vhd`: Module for driving the StickIt! LED module so it can 
    display numbers and letters.

`Common.vhd`: Commonly-used definitions and functions.
	
`ButtonScannerTest.ucf`: Pin assignments for connecting the XuLA FPGA
	board to the StickIt! Buttons and LED modules via the StickIt! motherboard.
   (If you are using a XuLA2 board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file.
   The [`xulate`](https://github.com/xesscorp/xulate) program will help you do that.)

`ButtonScannerTest.xise`: The Xilinx ISE project file that ties all the previous files together.

	
Running the Button Scanner Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
1. Insert a XuLA board into a StickIt! motherboard.
1. Attach a StickIt! Button module to the PM4 connector of the motherboard.
1. Attach a StickIt! LED module to the Wing3 connector of the motherboard.
1. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
1. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
   After the download completes, the first digit of the LED display should show a "-".
1. Press each button on the Button module. The hex digit corresponding to the
   button will appear on the first digit of the LED display.

