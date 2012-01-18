----------------------------------------------------------------------------------
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
-- 02111-1307, USA.
--
-- ©2011 - X Engineering Software Systems Corp. (www.xess.com)
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Module for scanning a button array.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.CommonPckg.all;

package ButtonScannerPckg is

  component ButtonScanner is
    generic(
      FREQ_G      : real := 100.0;      -- Operating frequency in MHz.
      SCAN_FREQ_G : real := 10.0  -- Desired frequency for scanning the buttons in KHz.
      );
    port(
      clk_i    : in    std_logic;
      b_io     : inout std_logic_vector(3 downto 0);
      button_o : out   std_logic_vector(12 downto 1)
      );
  end component;

end package;

library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;
use UNISIM.vcomponents.all;
use work.CommonPckg.all;

entity ButtonScanner is
  generic(
    FREQ_G      : real := 100.0;        -- Operating frequency in MHz.
    SCAN_FREQ_G : real := 1.0  -- Desired frequency for scanning the buttons in KHz.
    );
  port(
    clk_i    : in    std_logic;
    b_io     : inout std_logic_vector(3 downto 0);
    button_o : out   std_logic_vector(12 downto 1)
    );
end entity;

architecture arch of ButtonScanner is
  signal driverShf_r : unsigned(b_io'range)     := "1000";
  signal recvShf_r   : unsigned(b_io'range)     := "0100";
  signal buttonShf_r : unsigned(button_o'range) := "100000000000";
  signal bIn_s       : std_logic_vector(b_io'range);
begin

  process(clk_i)
    constant ALL_ZERO       : std_logic_vector(button_o'range) := (others => ZERO);
    -- The delay between scanning individual buttons is the total scan time divided by the number of buttons.
    constant MAX_CNTR       : natural                          := integer(ceil(FREQ_G * 1000.0 / (SCAN_FREQ_G * real(button_o'length))));
    variable scanCntr_v     : natural range 0 to MAX_CNTR;  -- Button scan timer.
    -- The buttons have to hold their values for a certain number of scans before they are accepted.
    constant DEBOUNCE_CNT   : natural                          := 10 * button_o'length;
    variable debounceCntr_v : natural range 0 to DEBOUNCE_CNT;
    -- The previous state of the buttons to which the current state is compared for debouncing.
    variable buttonState_v  : std_logic_vector(button_o'range) := (others => ZERO);
    variable buttonIn_v     : std_logic_vector(button_o'range);
  begin
    if rising_edge(clk_i) then
      if scanCntr_v /= 0 then  -- Wait until current button scan time has elapsed.
        scanCntr_v := scanCntr_v - 1;
      else  -- OK, now process the state of the currently-driven buttons.
        
        scanCntr_v := MAX_CNTR;  -- Reload the counter for the next scan.

        if (std_logic_vector(recvShf_r) and bIn_s) = "0000" then
          -- The currently driven button is not pressed.
          buttonIn_v := (others => ZERO);  -- Place a 0 in the current button's position.
        else
          -- The currently-driven button is pressed.
          buttonIn_v := std_logic_vector(buttonShf_r);  -- Place a 1 in the current button's position.
        end if;

        if ((buttonState_v xor buttonIn_v) and std_logic_vector(buttonShf_r)) /= ALL_ZERO then
          -- If the current button's state has changed from its previous value,
          -- then record its current value and reset the debounce counter.
          buttonState_v  := (buttonState_v and not std_logic_vector(buttonShf_r)) or buttonIn_v;
          debounceCntr_v := DEBOUNCE_CNT;
        else
          -- If the current button's state has not changed, then just decrement the debounce counter.
          debounceCntr_v := debounceCntr_v - 1;
          if debounceCntr_v = 0 then
            -- If the debounce counter has reached 0, then output the current state of the buttons.
            button_o(1)    <= buttonState_v(1);
            button_o(2)    <= buttonState_v(2);
            button_o(3)    <= buttonState_v(3);
            button_o(7)    <= buttonState_v(4);
            button_o(8)    <= buttonState_v(5);
            button_o(4)    <= buttonState_v(6);
            button_o(11)   <= buttonState_v(7);
            button_o(5)    <= buttonState_v(8);
            button_o(9)    <= buttonState_v(9);
            button_o(6)    <= buttonState_v(10);
            button_o(10)   <= buttonState_v(11);
            button_o(12)   <= buttonState_v(12);
            debounceCntr_v := DEBOUNCE_CNT;  -- Reset the debounce counter for the next scan.
          end if;
        end if;

        if (recvShf_r rol 1) = driverShf_r then
          -- If we've finished scanning all the buttons connected to this driver, then shift to the
          -- next driver and get ready to scan the buttons its connected to.
          driverShf_r <= driverShf_r rol 1;  -- Go to the next driver.
          recvShf_r   <= driverShf_r rol 2;  -- Receive from the next input just past the driver.
          buttonShf_r <= buttonShf_r rol 1;  -- Holds the bit mask for the next scanned button.
        else
          -- Not finished with the current driver, so shift to the next button connected to it.
          recvShf_r   <= recvShf_r rol 1;    -- Go to the next button input.
          buttonShf_r <= buttonShf_r rol 1;  -- Holds the bit mask for the next scanned button.
        end if;

      end if;
    end if;
  end process;

  IobufLoop : for i in b_io'low to b_io'high generate
--    UIobuf : IOBUF generic map(IOSTANDARD => "LVTTL") port map(T => recvShf_r(i), I => driverShf_r(i), O => bIn_s(i), IO => b_io(i));
    UIobuf : IOBUF generic map(IOSTANDARD => "LVTTL") port map(T => not driverShf_r(i), I => driverShf_r(i), O => bIn_s(i), IO => b_io(i));
  end generate;
end architecture;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.CommonPckg.all;
use work.ButtonScannerPckg.all;
use work.LedDigitsPckg.all;

entity ButtonScannerTest is
  generic (
    FREQ_G : real := 12.0               -- Operating frequency in MHz.
    );
  port (
    clk_i : in    std_logic;
    b_io  : inout std_logic_vector(3 downto 0);
    s_o   : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture arch of ButtonScannerTest is
  signal button_s   : std_logic_vector(12 downto 1);
  signal ledDigit_s : std_logic_vector(6 downto 0);
begin
  uButtons : ButtonScanner
    generic map (
      FREQ_G      => FREQ_G,
      SCAN_FREQ_G => 1.0
      )
    port map (
      clk_i    => clk_i,
      b_io     => b_io,
      button_o => button_s
      );

  process(button_s)
  begin
    case button_s is
      when "000000000001" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(1, ledDigit_s'length);
      when "000000000010" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(2, ledDigit_s'length);
      when "000000000100" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(3, ledDigit_s'length);
      when "000000001000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(4, ledDigit_s'length);
      when "000000010000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(5, ledDigit_s'length);
      when "000000100000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(6, ledDigit_s'length);
      when "000001000000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(7, ledDigit_s'length);
      when "000010000000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(8, ledDigit_s'length);
      when "000100000000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(9, ledDigit_s'length);
      when "001000000000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(10, ledDigit_s'length);
      when "010000000000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(11, ledDigit_s'length);
      when "100000000000" => ledDigit_s <= CONV_STD_LOGIC_VECTOR(12, ledDigit_s'length);
      when others         => ledDigit_s <= CONV_STD_LOGIC_VECTOR(16#2d#, ledDigit_s'length);
    end case;
  end process;

  uLeds : LedDigitsDisplay
    generic map(
      FREQ_G => FREQ_G
      )
    port map (
      clk_i        => clk_i,
      ledDigit1_i  => CharToLedDigit(ledDigit_s),
      ledDrivers_o => s_o
      );

end architecture;

