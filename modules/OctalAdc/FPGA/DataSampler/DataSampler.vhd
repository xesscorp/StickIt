--**********************************************************************
-- Copyright 2013 by XESS Corp <http://www.xess.com>.
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--**********************************************************************


library IEEE, XESS;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use XESS.CommonPckg.all;
use XESS.ClkGenPckg.all;
use XESS.SyncToClockPckg.all;
use XESS.HostIoPckg.all;
use XESS.SdramCntlPckg.all;
use XESS.AdcInterfacesPckg.all;
use XESS.PatternGenPckg.all;
use work.XessBoardPckg.all;

entity DataSampler is
  generic (
    FREQ_G        : real    := 8.0 * BASE_FREQ_C;  -- Master clock frequency in MHz.
    NUM_SAMPLES_G : natural := 1000000
    );
  port (
    fpgaClk_i : in    std_logic;
    -- ADC SPI port.
    cs_bo     : out   std_logic;
    sclk_o    : out   std_logic;
    mosi_o    : out   std_logic;
    miso_i    : in    std_logic;
    -- Sinusoidal output.
    sineRed_o : out   std_logic_vector(3 downto 0);
    sineGrn_o : out   std_logic_vector(4 downto 0);
    sineBlu_o : out   std_logic_vector(4 downto 0);
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

architecture arch of DataSampler is
  signal clk_s        : std_logic;      -- Master clock.
  -- HostIo JTAG signals.
  signal inShiftDr_s  : std_logic;
  signal drck_s       : std_logic;
  signal tdi_s        : std_logic;
  signal sdramTdo_s   : std_logic;
  signal adcTdo_s     : std_logic;
  -- Signals for SDRAM read port.
  signal rd_s         : std_logic := NO;
  signal rdAddr_s     : std_logic_vector(SDRAM_HADDR_WIDTH_C-1 downto 0);
  signal rdData_s     : std_logic_vector(SDRAM_DATA_WIDTH_C-1 downto 0);
  signal dummyData_s  : std_logic_vector(SDRAM_DATA_WIDTH_C-1 downto 0);
  signal rdOpBegun_s  : std_logic;
  signal rdDone_s     : std_logic;
  -- Signals for SDRAM write port.
  signal wr_s         : std_logic := NO;
  signal wrAddr_s     : std_logic_vector(SDRAM_HADDR_WIDTH_C-1 downto 0);
  signal wrData_s     : std_logic_vector(SDRAM_DATA_WIDTH_C-1 downto 0);
  signal wrOpBegun_s  : std_logic;
  signal wrDone_s     : std_logic;
  -- ADC sampling status and control signals.
  signal adcStatus_s  : std_logic_vector(1 downto 0);
  signal busy_s       : std_logic;
  signal done_s       : std_logic;
  signal adcControl_s : std_logic_vector(0 downto 0);
  signal run_s        : std_logic;
begin

  -- Take 12 MHz XuLA2 clock, generate a 96 MHz clock, send that to the SDRAM, and then
  -- input the SDRAM clock through another FPGA pin and use it as the main clock for
  -- this design. (This syncs the design and the SDRAM.) 
  uClk : ClkGen
    generic map(
      BASE_FREQ_G => BASE_FREQ_C,
      CLK_MUL_G   => integer(round(2.0 * FREQ_G / BASE_FREQ_C)),
      CLK_DIV_G   => 2
      )
    port map(i => fpgaClk_i, clkToLogic_o => sdClk_o);
  clk_s <= sdClkFb_i;

  -- Bring in the JTAG signals that connect to the SDRAM and ADC HostIo interface modules.
  uBscan : BscanToHostIo
    port map (
      inShiftDr_o => inShiftDr_s,
      drck_o      => drck_s,   -- Clock to the SDRAM and ADC interfaces.
      tdi_o       => tdi_s,             -- Bits to SDRAM and ADC interfaces.
      tdo_i       => sdramTdo_s,        -- Bits from the SDRAM interface.
      tdoa_i      => adcTdo_s  -- Bits from the ADC status/control interface.
      );

  -- Interface for sending SDRAM data back to PC.
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
      addr_o         => rdAddr_s,
      rd_o           => rd_s,
      dataToHost_i   => rdData_s,
      dataFromHost_o => dummyData_s,
      opBegun_i      => rdOpBegun_s,
      done_i         => rdDone_s
      );

  -- Interface for controlling/monitoring the ADC sampling.
  uHostIoToAdc : HostIoToDut
    generic map (
      ID_G => "11111110"                -- The ID this module responds to: 254.
      )
    port map (
      -- JTAG interface.
      inShiftDr_i     => inShiftDr_s,
      drck_i          => drck_s,
      tdi_i           => tdi_s,
      tdo_o           => adcTdo_s,
      -- ADC control/monitor interface.
      vectorToDut_o   => adcControl_s,
      vectorFromDut_i => adcStatus_s
      );

  -- Synchronize signal from PC that initiates sampling.  
  uSyncRun : SyncToClock
    port map(
      clk_i      => clk_s,
      unsynced_i => adcControl_s(0),    -- Sampling enable signal from PC.
      synced_o   => run_s               -- High when sampling is enabled.
      );

  adcStatus_s(0) <= busy_s;  -- High when ADC is sampling and storing data.
  adcStatus_s(1) <= done_s;  -- High when ADC has completed sampling and storing data.

  uAdc : Adc_088S_108S_128S_Intfc
    generic map (
      FREQ_G        => FREQ_G,
      SAMPLE_FREQ_G => 1.0
      )
    port map (
      clk_i         => clk_s,
      numChans_i    => "11",            -- Sample 3 channels.
      analogChans_i => "010001000",     -- Sample channels 0, 1, and 2.
--      numChans_i    => "1",       -- Sample 1 channel.
--      analogChans_i => "000",     -- Sample only channel 0.
      run_i         => run_s,
      startAddr_i   => std_logic_vector(TO_UNSIGNED(0, SDRAM_HADDR_WIDTH_C)),
      numSamples_i  => std_logic_vector(TO_UNSIGNED(NUM_SAMPLES_G, SDRAM_HADDR_WIDTH_C)),
      busy_o        => busy_s,
      done_o        => done_s,
      wr_o          => wr_s,
      sampleAddr_o  => wrAddr_s,
      sampleData_o  => wrData_s,
      wrDone_i      => wrDone_s,
      cs_bo         => cs_bo,
      sclk_o        => sclk_o,
      mosi_o        => mosi_o,
      miso_i        => miso_i
      );

  -- Dualport SDRAM controller.
  uDualPortSdram : DualPortSdram
    generic map (
      FREQ_G            => FREQ_G,
      PORT_TIME_SLOTS_G => "1111111111111110"
      )
    port map (
      clk_i => clk_s,

      -- Host-side port 0 connected to USB link so the PC can access the samples from the SDRAM.
      rd0_i      => rd_s,
      opBegun0_o => rdOpBegun_s,
      addr0_i    => rdAddr_s,
      data0_o    => rdData_s,
      done0_o    => rdDone_s,

      -- Host-side port 1 connected to ADC interface so the samples can be written to SDRAM.
      wr1_i   => wr_s,
      addr1_i => wrAddr_s,
      data1_i => wrData_s,
      done1_o => wrDone_s,

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

  -- Sine wave generators connect to a StickIt! VGA board to create analog signals for 
  -- testing multiple ADC channels.

  uSineRedGen : SineGen  -- A four-bit DAC drives the red VGA component.
    port map(
      clk_i       => clk_s,
      freq_i      => std_logic_vector(TO_UNSIGNED(10, 20)),  -- 10 * 96 MHz / 2^20 = 915 Hz.
      amplitude_i => std_logic_vector(TO_UNSIGNED(7, 4)),
      offset_i    => std_logic_vector(TO_UNSIGNED(7, 4)),
      sine_o      => sineRed_o
      );

  uSineGrnGen : SineGen  -- A five-bit DAC drives the green VGA component.
    port map(
      clk_i       => clk_s,
      freq_i      => std_logic_vector(TO_UNSIGNED(20, 20)),  -- 20 * 96 MHz / 2^20 = 1830 Hz.
      amplitude_i => std_logic_vector(TO_UNSIGNED(10, 5)),
      offset_i    => std_logic_vector(TO_UNSIGNED(10, 5)),
      sine_o      => sineGrn_o
      );

  uSineBluGen : SineGen  -- A five-bit DAC drives the blue VGA component.
    port map(
      clk_i       => clk_s,
      freq_i      => std_logic_vector(TO_UNSIGNED(30, 20)),  -- 30 * 96 MHz / 2^20 = 2745 Hz.
      amplitude_i => std_logic_vector(TO_UNSIGNED(15, 5)),
      offset_i    => std_logic_vector(TO_UNSIGNED(15, 5)),
      sine_o      => sineBlu_o
      );

end architecture;
