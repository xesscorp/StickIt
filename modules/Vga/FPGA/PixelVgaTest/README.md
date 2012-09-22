Pixel-Mode VGA Test Design
======================================================

This FPGA design reads an image from SDRAM and displays it on a VGA monitor.


Important Files
-----------------------------------------------------

`Vga.vhd`: Module for displaying a pixel-mode or text-mode image on a monitor
    via a StickIt! VGA module. It also contains the test module.

`ClkGen.vhd`: Module for generating a new clock frequency from the master clock (usually 12 MHz).

`SdramCntl.vhd`: Module for managing read/write access to the SDRAM on the XuLA board.

`Common.vhd`: Commonly-used definitions and functions.
	
`PixelVgaTest.ucf`: Pin assignments for connecting the XuLA FPGA
	board to the StickIt! VGA module via the StickIt! motherboard.
   (If you are using a XuLA2 board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file.
   The [`xulate`](https://github.com/xesscorp/xulate) program will help you do that.)

`PixelVgaTest.xise`: The Xilinx ISE project file that ties all the previous files together.

`image.xes`: A sample image file that is loaded into the XuLA SDRAM.

	
Running the Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
1. Insert a XuLA board into a StickIt! motherboard.
1. Attach a StickIt! VGA module to the WING3 and WING2 connectors of the motherboard.
   Then plug a monitor into the VGA module.
1. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
1. Use `XSLOAD` or `GXSLOAD` to download the `image.xes` and `.bit` files to the SDRAM and FPGA on the XuLA board.
   After the download completes, an image should appear on the monitor.

