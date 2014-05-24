--**********************************************************************
-- Copyright (c) 2014 by XESS Corp <http://www.xess.com>.
-- All rights reserved.
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 3.0 of the License, or (at your option) any later version.
-- 
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.  If not, see 
-- <http://www.gnu.org/licenses/>.
--**********************************************************************

library IEEE, XESS;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use XESS.CommonPckg.all;
use XESS.MiscPckg.all;
use XESS.ClkGenPckg.all;
use XESS.SyncToClockPckg.all;
use XESS.HostIoPckg.all;
use XESS.SdramCntlPckg.all;
use XESS.AudioPckg.all;
use work.XessBoardPckg.all;

entity RecordPlayback is
  generic (
    FREQ_G        : real    := 100.0;  -- Master clock frequency in MHz.
    NUM_SAMPLES_G : natural := 1000000
    );
  port (
    fpgaClk_i : in    std_logic;
    -- Connections to StickIt! AudioIO board.
    mclk_o    : out   std_logic;
    sclk_o    : out   std_logic;
    lrck_o    : out   std_logic;
    sdti_o    : out   std_logic;
    sdto_i    : in    std_logic;
    csn_o     : out   std_logic;
    cclk_o    : out   std_logic;
    -- SDRAM port.
    sdCke_o   : out   std_logic;
    sdClk_o   : out   std_logic;
    sdClkFb_i : in    std_logic;
    sdCe_bo   : out   std_logic;
    sdRas_bo  : out   std_logic;
    sdCas_bo  : out   std_logic;
    sdWe_bo   : out   std_logic;
    sdDqml_o  : out   std_logic;
    sdDqmh_o  : out   std_logic;
    sdBs_o    : out   std_logic_vector(1 downto 0);
    sdAddr_o  : out   std_logic_vector(SDRAM_SADDR_WIDTH_C-1 downto 0);
    sdData_io : inout std_logic_vector(SDRAM_DATA_WIDTH_C-1 downto 0)
    );
end entity;

architecture arch of RecordPlayback is
  subtype SdramAddr_t is std_logic_vector(SDRAM_HADDR_WIDTH_C-1 downto 0);
  subtype SdramData_t is std_logic_vector(SDRAM_DATA_WIDTH_C-1 downto 0);
  subtype CodecData_t is std_logic_vector(19 downto 0);

  signal clk_s              : std_logic;  -- Master clock.
  -- HostIo JTAG signals.
  signal inShiftDr_s        : std_logic;
  signal drck_s             : std_logic;
  signal tdi_s              : std_logic;
  signal sdramTdo_s         : std_logic;
  signal codecTdo_s         : std_logic;
  -- Signals for HostIo-SDRAM port.
  signal hostRd_s           : std_logic   := NO;
  signal hostWr_s           : std_logic   := NO;
  signal hostAddr_s         : SdramAddr_t;
  signal hostRdData_s       : SdramData_t;
  signal hostWrData_s       : SdramData_t;
  signal hostOpBegun_s      : std_logic;
  signal hostDone_s         : std_logic;
  -- Signals for Codec-SDRAM port.
  signal codecRd_s          : std_logic   := NO;
  signal codecHshkRd_s      : std_logic;
  signal codecWr_s          : std_logic   := NO;
  signal codecHshkWr_s      : std_logic;
  signal codecAddr_s        : SdramAddr_t;
  signal codecRdData_s      : SdramData_t;
  signal codecWrData_s      : SdramData_t;
  signal codecOpBegun_s     : std_logic;
  signal codecDone_s        : std_logic;
  signal codecHshkDone_s    : std_logic;
  -- Codec sampling status and control signals.
  signal codecStatus_s      : std_logic_vector(1 downto 0);
  signal busy_s             : std_logic;
  signal done_s             : std_logic;
  signal codecControl_s     : std_logic_vector(1 downto 0);
  signal run_s              : std_logic;
  signal play_s             : std_logic;
  -- Codec input/output data buses.
  signal leftInput_s        : CodecData_t;
  signal rightInput_s       : CodecData_t;
  signal leftInput_r        : CodecData_t;
  signal rightInput_r       : CodecData_t;
  signal leftOutput_r       : CodecData_t;
  signal rightOutput_r      : CodecData_t;
  signal xfer_s             : std_logic;
  -- Codec SDRAM FSM address and counters.
  signal numInputSamples_s  : SdramAddr_t;
  signal inputSampleCntr_r  : SdramAddr_t;
  signal startInputAddr_s   : SdramAddr_t := SdramAddr_t(TO_UNSIGNED(0, SdramAddr_t'length));
  signal inputAddr_r        : SdramAddr_t;
  signal inputDone_r        : std_logic;
  signal numOutputSamples_s : SdramAddr_t;
  signal outputSampleCntr_r : SdramAddr_t;
  signal startOutputAddr_s  : SdramAddr_t := SdramAddr_t(TO_UNSIGNED(0, SdramAddr_t'length));
  signal outputAddr_r       : SdramAddr_t;
  signal outputDone_r       : std_logic;
  
begin

  -- Take 12 MHz XuLA2 clock, generate a 96 MHz clock, send that to the SDRAM, and then
  -- input the SDRAM clock through another FPGA pin and use it as the main clock for
  -- this design. (This syncs the design and the SDRAM.) 
  uClk : ClkGen
    generic map(
      BASE_FREQ_G => BASE_FREQ_C,
      CLK_MUL_G   => 25,
      CLK_DIV_G   => 3
      )
    port map(i => fpgaClk_i, clkToLogic_o => sdClk_o);
  clk_s <= sdClkFb_i;

  -- Bring in the JTAG signals that connect to the SDRAM and ADC HostIo interface modules.
  uBscan : BscanToHostIo
    port map (
      inShiftDr_o => inShiftDr_s,
      drck_o      => drck_s,     -- Clock to the SDRAM and ADC interfaces.
      tdi_o       => tdi_s,             -- Bits to SDRAM and ADC interfaces.
      tdo_i       => sdramTdo_s,        -- Bits from the SDRAM interface.
      tdoa_i      => codecTdo_s  -- Bits from the codec status/control interface.
      );

  -- Interface for sending SDRAM data back and forth to PC.
  uHostIoToSdram : HostIoToRam
    generic map (
      ID_G       => "11111111",         -- The ID this module responds to: 255.
      ADDR_INC_G => 1  -- Increment address after each read to point to next data location.
      )
    port map (
      -- JTAG interface.
      inShiftDr_i    => inShiftDr_s,
      drck_i         => drck_s,
      tdi_i          => tdi_s,
      tdo_o          => sdramTdo_s,
      -- RAM signals that go to one port of the dualport SDRAM controller.
      clk_i          => clk_s,
      addr_o         => hostAddr_s,
      rd_o           => hostRd_s,
      wr_o           => hostWr_s,
      dataToHost_i   => hostRdData_s,
      dataFromHost_o => hostWrData_s,
      opBegun_i      => hostOpBegun_s,
      done_i         => hostDone_s
      );

  -- Interface for controlling/monitoring the codec sampling.
  uHostIoToCodec : HostIoToDut
    generic map (
      ID_G => "11111110"                -- The ID this module responds to: 254.
      )
    port map (
      -- JTAG interface.
      inShiftDr_i     => inShiftDr_s,
      drck_i          => drck_s,
      tdi_i           => tdi_s,
      tdo_o           => codecTdo_s,
      -- Codec control/monitor interface.
      vectorToDut_o   => codecControl_s,
      vectorFromDut_i => codecStatus_s
      );

  -- Synchronize signal from PC that initiates sampling.  
  uSyncRun : SyncToClock
    port map(
      clk_i      => clk_s,
      unsynced_i => codecControl_s(0),  -- Sampling enable signal from PC.
      synced_o   => run_s               -- High when sampling is enabled.
      );
      
  uPlayRcrd : SyncToClock
    port map(
      clk_i => clk_s,
      unsynced_i => codecControl_s(1),
      synced_o => play_s -- Low when recording, high when playing back recorded audio.
    );
    
  -- When recording, set the number of samples to gather at the maximum the SDRAM can store.
  -- When playing back, set the number of samples to gather to zero so the previously stored samples aren't disturbed.
  numInputSamples_s <= SdramAddr_t(TO_UNSIGNED(16000000, SdramAddr_t'length)) when play_s = LO else
                       SdramAddr_t(TO_UNSIGNED(0, SdramAddr_t'length));
  -- When recording, set the number of samples to output to zero so the audio output stays quiet.
  -- When playing back, set the number of samples to output to the number of samples that were stored previously.
  numOutputSamples_s <= inputSampleCntr_r when play_s = HI else
                       SdramAddr_t(TO_UNSIGNED(0, SdramAddr_t'length));

  codecStatus_s(0) <= not inputDone_r or not outputDone_r;  -- High while codec is sampling and outputting data.
  codecStatus_s(1) <= inputDone_r and outputDone_r;  -- High when codec has completed sampling and outputting data.

  -- Audio codec interface module.
  uCodec : Audio
    generic map(
      FREQ_G => FREQ_G,
      INPUT_SOURCE_G => MIC_INPUT_C,
      INPUT_GAIN_G => 28.0
      )
    port map(
      rst_i => NO,
      clk_i => clk_s,

      -- Interface to FSM that reads/writes samples to the SDRAM.
      xfer_o     => xfer_s,
      leftAdc_o  => leftInput_s,
      rightAdc_o => rightInput_s,
      leftDac_i  => leftOutput_r,
      rightDac_i => rightOutput_r,

      -- I/O to StickIt! AudioIO board.
      mclk_o => mclk_o,
      sclk_o => sclk_o,
      lrck_o => lrck_o,
      sdti_o => sdti_o,
      sdto_i => sdto_i,
      csn_o  => csn_o,
      cclk_o => cclk_o
      );
      
  -- Module that reads/writes samples to the SDRAM.
  uCodecToSdram : AudioRamIntfc
    port map(
      clk_i => clk_s,
      rcrdStartAddr_i => startInputAddr_s,
      numRcrdSamples_i => numInputSamples_s,
      rcrdSampleCntr_o => inputSampleCntr_r,
      playStartAddr_i => startOutputAddr_s,
      numPlaySamples_i => numOutputSamples_s,
      playSampleCntr_o => outputSampleCntr_r,
      run_i => run_s,
      rcrdDone_o => inputDone_r,
      playDone_o => outputDone_r,
      xfer_i => xfer_s,
      rcrdLeft_i => leftInput_s,
      rcrdRight_i => rightInput_s,
      playLeft_o => leftOutput_r,
      playRight_o => rightOutput_r,
      ramAddr_o => codecAddr_s,
      ramData_i => codecRdData_s,
      ramData_o => codecWrData_s,
      ramRd_o => codecRd_s,
      ramWr_o => codecWr_s,
      ramDone_i => codecDone_s
    );

  -- Module that converts the R/W controls of the SDRAM interface into a handshake format
  -- that's easier for the Audio Ram interface to handle.
  uHandshake : RWHandshake
    port map(
      rd_i   => codecRd_s,
      rd_o   => codecHshkRd_s,
      wr_i   => codecWr_s,
      wr_o   => codecHshkWr_s,
      done_i => codecHshkDone_s,
      done_o => codecDone_s
      );

  -- Dualport SDRAM controller.
  uDualPortSdram : DualPortSdram
    generic map (
      FREQ_G            => FREQ_G,
      PORT_TIME_SLOTS_G => "1111111111111110"
      )
    port map (
      clk_i => clk_s,

      -- Host-side port 0 connected to USB link so the PC can upload/download the samples to/from the SDRAM.
      rd0_i      => hostRd_s,
      wr0_i      => hostWr_s,
      addr0_i    => hostAddr_s,
      data0_o    => hostRdData_s,
      data0_i    => hostWrData_s,
      opBegun0_o => hostOpBegun_s,
      done0_o    => hostDone_s,

      -- Host-side port 1 connected to codec so the samples can be read/written to SDRAM.
      rd1_i      => codecHshkRd_s,
      wr1_i      => codecHshkWr_s,
      addr1_i    => codecAddr_s,
      data1_o    => codecRdData_s,
      data1_i    => codecWrData_s,
      opBegun1_o => codecOpBegun_s,
      done1_o    => codecHshkDone_s,

      -- SDRAM side.
      sdCke_o   => sdCke_o,
      sdCe_bo   => sdCe_bo,
      sdRas_bo  => sdRas_bo,
      sdCas_bo  => sdCas_bo,
      sdWe_bo   => sdWe_bo,
      sdBs_o    => sdBs_o,
      sdAddr_o  => sdAddr_o,
      sdData_io => sdData_io,
      sdDqmh_o  => sdDqmh_o,
      sdDqml_o  => sdDqml_o
      );

end architecture;
