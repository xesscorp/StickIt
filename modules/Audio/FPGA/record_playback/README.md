Audio Record/Playback Test Design
======================================================

This design uses the AudioIO board to record input from a microphone and store it in the SDRAM.
Then, the recorded waveform can be played back through the stereo output port.


Important Files
-----------------------------------------------------

`record_playback.vhd`:
    This file contains the top-level VHDL file that ties together all the submodules for this design.
    
`XuLA2.ucf`: 
   Pin assignments for connecting the XuLA2 FPGA board to the StickIt! AudioIO module via the 
   StickIt! motherboard.(If you are using a XuLA board, then you will need to translate the 
   XuLA pin assignments in the `.ucf` file. The [`xulate`](https://github.com/xesscorp/xulate) 
   program will help you do that.)

`record_playback.xise`: 
   The Xilinx ISE project file that ties all the previous files together.
   
`gui_record_playback.py`:
   GUI Python script that controls recording and playback for this design.
   
`RecordPlayback.py`:
   Command-line Python script that controls recording and playback for this design.

   
Really, Really Important Note!!!
==========================================

This project uses the new unified library of VHDL components stored in the
[VHDL_Lib repository](https://github.com/xesscorp/VHDL_Lib). If you try to compile 
this project and you get a bunch of warnings about missing files, then you don't 
have this library installed or it's in the wrong place. Please look in the 
[VHDL_Lib README](https://github.com/xesscorp/VHDL_Lib/blob/master/README.rst) for 
instructions on how to install and use it.


Running the Test
-----------------------------------------------------

1. Load the `.xise` project file with ISE and compile it into a `.bit` file.
2. Insert a XuLA2 board into a StickIt! motherboard.
3. Attach a StickIt! AudioIO module to the PMOD2 connector of the motherboard.
4. Connect a microphone to the AudioIO board stereo input jack.
5. Connect a speaker or headphones to the AudioIO board stereo output jack.
6. Attach a USB cable to the XuLA2 board. (This will supply power for the
   entire collection of boards and modules.)
7. Use `XSLOAD` or `GXSLOAD` to download the `.bit` file to the FPGA on the XuLA board.
8. Run the Python script.
9. Click the `Record` and `Playback` buttons to record and playback audio captured
   through the microphone.

You can also look at this [video](https://www.youtube.com/watch?v=UklDj0gXyjk) that shows how to run the test.

