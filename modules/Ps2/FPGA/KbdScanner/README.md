PS/2 Keyboard Scanner Test Design
======================================================

This FPGA design displays some scrolling text on the 
StickIt! LED Digits module.
This FPGA design accepts keystrokes from a PS/2 keyboard and StickIt! PS/2 module and displays
the keyboard character on LED1 of a StickIt! LED Digits module.


Important Files
-----------------------------------------------------

`KbdScanner.vhd`: Module for scanning a PS/2 keyboard attached through a StickIt! PS/2 module.
	It also contains the test module.

`LedDigits.vhd`: Module for driving the StickIt! LED Digits module so it can 
    display numbers and letters.

`Common.vhd`: Commonly-used definitions and functions.
	
`KbdScannerTest.ucf`: Pin assignments for connecting the XuLA FPGA
	board to the StickIt! PS/2 and LED Digits modules via the StickIt! motherboard.
   (If you are using a XuLA2 board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file.
   The [`xulate`](https://github.com/xesscorp/xulate) program will help you do that.)

`KbdScannerTest.xise`: The Xilinx ISE project file that ties all the previous files together.

	
Running the PS/2 Keyboard Scanner Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
1. Insert a XuLA board into a StickIt! motherboard.
1. Attach a StickIt! PS/2 module to the PM4 connector of the motherboard.
   Then plpug a PS/2 keyboard into the PS/2 module.
1. Attach a StickIt! LED Digits module to the WING3 connector of the motherboard.
1. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
1. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
1. Press keys on the PS/2 keyboard. The corresponding character should appear on LED1
   of the LED Digits module.

