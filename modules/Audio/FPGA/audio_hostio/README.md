Audio I/O Test Design
======================================================

This design allows a host PC to load a stereo waveform into the XuLA SDRAM and then have this
waveform sent through the StickIt! AudioIO stereo output port. If the output port is looped back
to the input port, then the waveform will be sampled and stored in another area of the SDRAM.
This sampled waveform can be downloaded by the host PC and compared against what was originally sent.


Important Files
-----------------------------------------------------

`audio_hostio.vhd`:
    This file contains the top-level VHDL file that ties together all the submodules for this design.
    
`XuLA2.ucf`: 
   Pin assignments for connecting the XuLA2 FPGA board to the StickIt! Audio I/O module via the 
   StickIt! motherboard.(If you are using a XuLA board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file. The [`xulate`](https://github.com/xesscorp/xulate) 
   program will help you do that.)

`audio_hostio.xise`: 
   The Xilinx ISE project file that ties all the previous files together.
   
`AudioHostio.py`:
   Python script that tests this design.

   
Really, Really Important Note!!!
==========================================

This project uses the new unified library of VHDL components stored in the
`VHDL_Lib repository <https://github.com/xesscorp/VHDL_Lib>`_. If you try to compile 
this project and you get a bunch of warnings about missing files, then you don't 
have this library installed or it's in the wrong place. Please look in the 
[VHDL_Lib README](https://github.com/xesscorp/VHDL_Lib/blob/master/README.rst) for 
instructions on how to install and use it.


Running the Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
2. Insert a XuLA2 board into a StickIt! motherboard.
3. Attach a StickIt! Audio I/O module to the PMOD2 connector of the motherboard.
4. Connect a stereo cable from the AudioIO board output to its input.
5. Attach a USB cable to the XuLA2 board. (This will supply power for the
   entire collection of boards and modules.)
6. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
7. Run the Python script.

You can also look at this [video](https://www.youtube.com/watch?v=wwVOjgeXawE) that shows how to run the test.

