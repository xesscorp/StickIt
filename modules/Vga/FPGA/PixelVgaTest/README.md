Pixel-Mode VGA Test Design
======================================================

This FPGA design reads an image from SDRAM and displays it on a VGA monitor.


Important Files
-----------------------------------------------------

All the VHDL files for this design are now part of the [XESS VHDL library](https://github.com/xesscorp/VHDL_Lib).
Look at that repo for instructions on using the library. Here are the library files used in this project:

`Vga.vhd`: Module for displaying a pixel-mode or text-mode image on a monitor
    via a StickIt! VGA module. It also contains the `PixelVgaTest` test module.

`ClkGen.vhd`: Module for generating a new clock frequency from the master clock (usually 12 MHz).

`SdramCntl.vhd`: Module for managing read/write access to the SDRAM on the XuLA board.

`fifo.vhd`: Module containing several FIFO modules.

`Common.vhd`: Commonly-used definitions and functions.
	
`PixelVgaTest-xula.ucf`: Pin assignments for connecting the XuLA FPGA
	board to the StickIt! VGA module via the StickIt! motherboard.
	
`PixelVgaTest-xula2.ucf`: Pin assignments for connecting the XuLA2 FPGA
	board to the StickIt! VGA module via the StickIt! motherboard.

`PixelVgaTest.xise`: The Xilinx ISE project file that ties all the previous files together.

`img_800x600.xes`: An 800x600 image file that can be loaded into the XuLA SDRAM.

`img_1024x792.xes`: A 1024x792 image file that can be loaded into the XuLA SDRAM.

	
Running the 800x600 Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
1. Insert a XuLA board into a StickIt! motherboard.
1. Attach a StickIt! VGA module to the WING3 and WING2 connectors of the motherboard.
   Then plug a monitor into the VGA module.
1. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
1. Use `XSLOAD` or `GXSLOAD` to download the `img_800x600.xes` and `.bit` files to the SDRAM and FPGA on the XuLA board.
   After the download completes, an image should appear on the monitor.

	
Running the 1024x768 Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and make the following changes:
    1. On line 844, change `FREQ_G` to 64.8.
    1. On line 845, change `CLK_DIV_G` to 1, making the pixel clock the same as the main clock.
    1. On line 847, change `PIXELS_PER_LINE_G` to 1024.
    1. On line 848, change `LINES_PER_FRAME_G` to 768.
    1. Change line 886 to `generic map (BASE_FREQ_G => 12.0, CLK_MUL_G => 27, CLK_DIV_G => 5)`.
       This changes the clock frequency to 12.0 * 27/5 = 64.8 MHz.
1. Insert a XuLA board into a StickIt! motherboard.
1. Attach a StickIt! VGA module to the WING3 and WING2 connectors of the motherboard.
   Then plug a monitor into the VGA module.
1. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
1. Use `XSLOAD` or `GXSLOAD` to download the `img_1024x792.xes` and `.bit` files to the SDRAM and FPGA on the XuLA board.
   After the download completes, an image should appear on the monitor. The bottom of the image will be clipped off
   because it's height (792) is greater than the screen height (768).

