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

--*********************************************************************
-- Test for StickIt! MPU module.
--*********************************************************************

--**********************************************************************
-- This is a simple design for testing the interface between a host PC
-- and an I2C peripheral chip.
--**********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.CommonPckg.all;
use work.ClkGenPckg.all;
use work.HostIoToI2cPckg.all;
--library unisim;
--use unisim.vcomponents.all;

entity MPUTest is
  port (
    fpgaClk_i : in    std_logic;        -- XuLA 12 MHz clock.
    fsync_o   : out   std_logic;
    int_i     : in    std_logic;
    clkin_o   : out   std_logic;
    scl_io    : inout std_logic;       -- I2C bus clock line.
    sda_io    : inout std_logic        -- I2C bus data line.
    );
end entity;

architecture arch of MPUTest is
  signal clk_s   : std_logic;           -- Clock.
  signal reset_s : std_logic := LO;     -- Active-high reset.
begin

  fsync_o <= LO;
  clkin_o <= LO;

  -- Generate 100 MHz clock from 12 MHz XuLA clock.
  u0 : ClkGen generic map(CLK_MUL_G => 25, CLK_DIV_G => 3) port map(i => fpgaClk_i, o => clk_s);

  -- Generate a reset pulse to initialize the modules.
  process (clk_s)
    variable rstCnt_v : integer range 0 to 15 := 10;  -- Set length of rst pulse.
  begin
    if rising_edge(clk_s) then
      reset_s <= HI;                    -- Activate rst.
      if rstCnt_v = 0 then
        reset_s <= LO;                  -- Release rst when counter hits 0.
      else
        rstCnt_v := rstCnt_v - 1;
      end if;
    end if;
  end process;

  -- Instantiate the JTAG-to-I2C interface.
  u1 : HostIoToI2c
    generic map(
      SIMPLE_G => true
      )
    port map(
      reset_i => reset_s,
      clk_i   => clk_s,
      scl_io  => scl_io,
      sda_io  => sda_io
      );

end architecture;
