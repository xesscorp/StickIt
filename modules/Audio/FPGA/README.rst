==========================================
StickIt! AudioIO Board FPGA Design Examples
==========================================

This directory contains the following subdirectories of FPGA example designs for the StickIt! AudioIO board:

    audio/:
        A simple loopback example that takes whatever signal is on the AudioIO stereo input port and
        echoes it to the stereo output port.

    audio_hostio/:
        This design allows a host PC to load a stereo waveform into the XuLA SDRAM and then have this
        waveform sent through the StickIt! AudioIO stereo output port. If the output port is looped back
        to the input port, then the waveform will be sampled and stored in another area of the SDRAM.
        This sampled waveform can be downloaded by the host PC and compared against what was originally sent.

    record_playback/:
        This design uses the AudioIO board to record input from a microphone and store it in the SDRAM.
        Then, the recorded waveform can be played back through the stereo output port.

        
Really, Really Important Note!!!
==========================================

Some of these projects use the new unified library of VHDL components stored in the
`VHDL_Lib repository <https://github.com/xesscorp/VHDL_Lib>`_. If you try to compile 
these projects and you get a bunch of warnings about missing files, then you don't 
have this library installed or it's in the wrong place. Please look in the 
`VHDL_Lib README <https://github.com/xesscorp/VHDL_Lib/blob/master/README.rst>`_ for 
instructions on how to install and use it.
