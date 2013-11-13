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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.CommonPckg.all;
use work.ClkGenPckg.all;
use work.LedDigitsPckg.all;
use work.SyncToClockPckg.all;
use work.HostIoPckg.all;
use work.RotaryEncoderPckg.all;

entity RotaryEncoderTest is
  port (
    clk_i       : in  std_logic;
    rotEncA_i   : in  std_logic;        -- Rotary encoder phase 1 output.
    rotEncB_i   : in  std_logic;        -- Rotary encoder phase 2 output.
    rotEncBtn_i : in  std_logic;        -- Rotary encoder pushbutton.
    led_o       : out std_logic_vector (7 downto 0)
    );
end entity;

architecture arch of RotaryEncoderTest is
  signal clk_s         : std_logic;
  signal accumulator_s : std_logic_vector(31 downto 0);
  signal dummy_s       : std_logic_vector(0 downto 0);
begin

  u0 : ClkGen
    generic map (BASE_FREQ_G => 12.0, CLK_MUL_G => 25, CLK_DIV_G => 3)
    port map (i              => clk_i, o => clk_s);

  u1 : RotaryEncoderWithCounter
    generic map (ALLOW_ROLLOVER_G => true, INITIAL_CNT_G => 0)
    port map (
      clk_i => clk_s,
      a_i   => rotEncA_i,
      b_i   => rotEncB_i,
      cnt_o => accumulator_s
      );

  u2 : LedHexDisplay
    port map (
      clk_i          => clk_s,
      hexAllDigits_i => accumulator_s,
      ledDrivers_o   => led_o
      );

  u3 : HostIoToDut
    generic map (
      --FPGA_DEVICE_G => SPARTAN3A, -- Use this for XuLA.
      FPGA_DEVICE_G => SPARTAN6,        -- Use this for XuLA2.
      SIMPLE_G      => true
      )
    port map (
      vectorFromDut_i => accumulator_s,
      vectorToDut_o   => dummy_s
      );

end architecture;

