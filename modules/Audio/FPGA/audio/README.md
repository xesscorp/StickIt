Audio I/O Test Design
======================================================

This FPGA design digitizes a stereo signal on the input jack
of the StickIt! Audio I/O module and then reconverts it to
an analog signal and sends it back through the stereo output jack.


Important Files
-----------------------------------------------------

`audio.vhd`:
    This file contains the stereo audio codec interface module and then uses it to
    interface to digitize a stereo input waveform and then convert it back into an analog output.
    You can get a more detailed description of the codec interface at http://www.xess.com/appnotes/an-032904-codec.pdf .
    
`clkgen.vhd`:
   This is a clock generator that synthesizes a higher frequency clock from the 12 MHz clock on the XuLA board.
   
`common.vhd`:
   This file contains some definitions and functions used in the rest of the VHDL code.

`audio.ucf`: 
   Pin assignments for connecting the XuLA FPGA
   board to the StickIt! Audio I/O module via the StickIt! motherboard.
   (If you are using a XuLA2 board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file.
   The [`xulate`](https://github.com/xesscorp/xulate) program will help you do that.)

`audio.xise`: 
   The Xilinx ISE project file that ties all the previous files together.

Running the Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
2. Insert a XuLA board into a StickIt! motherboard.
3. Attach a StickIt! Audio I/O module to the WING3 connector of the motherboard.
4. Attach a USB cable to the XuLA board. (This will supply power for the
   entire collection of boards and modules.)
5. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
6. Attach a stereo source (such as the lineout port of a PC) to the input jack of 
   the StickIt! Audio I/O module. Attach a set of headphones to the output jack.
   You should hear the sound from the PC's lineout port replicated on the output
   port of the StickIt! Audio I/O module.

