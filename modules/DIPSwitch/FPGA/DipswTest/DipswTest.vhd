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
-- Test for DIP switch StickIt! module.
--*********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.CommonPckg.all;
use work.HostIoPckg.all;

entity DipswTest is
  generic (
    FREQ_G : real := 12.0               -- Operating frequency in MHz.
    );
  port (
    dipsw_i  : in std_logic_vector(8 downto 1)
    );
end entity;

architecture arch of DipswTest is
  signal waste   : std_logic_vector(0 downto 0);
begin

  u1: HostIoToDut
    generic map (
      ID_G               => "11111111",  -- The ID this module responds to.
      SIMPLE_G           => true  -- If true, include BscanToHostIo module in this module.
      )
    port map ( vectorFromDut_i => dipsw_i, vectorToDut_o => waste );

end architecture;

