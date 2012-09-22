--*********************************************************************
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
-- ©2012 - X Engineering Software Systems Corp. (www.xess.com)
--*********************************************************************


--*********************************************************************
-- PS/2 keyboard interface module.
--*********************************************************************


library IEEE;
use IEEE.std_logic_1164.all;
use work.CommonPckg.all;

package Ps2KbdPckg is

--*********************************************************************
-- This function takes a PS/2 keyboard scan code and translates it into
-- an equivalent ASCII character.
--*********************************************************************
  function scanCodeToAscii(
    scanCode_i : std_logic_vector       -- PS/2 keyboard scan code.
    ) return std_logic_vector;  -- Return ASCII code equivalent of PS/2 keyboard scan code.

--*********************************************************************
-- This module accepts a serial datastream and clock from a PS/2 keyboard
-- and outputs the scan code for any key that is pressed.
--*********************************************************************
  component Ps2KbdScanner is
    generic(
      FREQ_G : real := 100.0            -- Frequency of the main clock (MHz).
      );
    port(
      clk_i      : in  std_logic;       -- Main clock.
      rst_i      : in  std_logic := NO;  -- Asynchronous reset.
      ps2Clk_i   : in  std_logic;       -- Clock from PS/2 keyboard.
      ps2Data_i  : in  std_logic;       -- Serial data from PS/2 keyboard.
      scanCode_o : out std_logic_vector(7 downto 0);  -- PS/2 keyboard scan code.
      rdy_o      : out std_logic := NO;  -- Pulses high when a scan code is ready.
      error_o    : out std_logic := NO  -- Goes high when there is an error receiving scan code.
      );
  end component;

end package;




--*********************************************************************
-- This function takes a PS/2 keyboard scan code and translates it into
-- an equivalent ASCII character.
--*********************************************************************

library IEEE;
use IEEE.numeric_std.all;

package body Ps2KbdPckg is

  function scanCodeToAscii(
    scanCode_i : std_logic_vector       -- PS/2 keyboard scan code.
    ) return std_logic_vector is  -- Return ASCII code equivalent of PS/2 keyboard scan code.
    variable ascii_o : natural range 0 to 127;  -- ASCII code equivalent of PS/2 keyboard scan code.
  begin
    case TO_INTEGER(unsigned(scanCode_i)) is
      when 16#29# => ascii_o := 16#20#;         -- Space.
      when 16#4e# => ascii_o := 16#2d#;         -- Minus sign (-).
      when 16#45# => ascii_o := 16#30#;         -- Zero.
      when 16#16# => ascii_o := 16#31#;         -- One.
      when 16#1e# => ascii_o := 16#32#;         -- Two. 
      when 16#26# => ascii_o := 16#33#;         -- Three.
      when 16#25# => ascii_o := 16#34#;         -- Four.
      when 16#2e# => ascii_o := 16#35#;         -- Five.
      when 16#36# => ascii_o := 16#36#;         -- Six.
      when 16#3d# => ascii_o := 16#37#;         -- Seven.
      when 16#3e# => ascii_o := 16#38#;         -- Eight.
      when 16#46# => ascii_o := 16#39#;         -- Nine.
      when 16#1c# => ascii_o := 16#41#;         -- a
      when 16#32# => ascii_o := 16#42#;         -- b
      when 16#21# => ascii_o := 16#43#;         -- c
      when 16#23# => ascii_o := 16#44#;         -- d
      when 16#24# => ascii_o := 16#45#;         -- e
      when 16#2b# => ascii_o := 16#46#;         -- f
      when 16#34# => ascii_o := 16#47#;         -- g
      when 16#33# => ascii_o := 16#48#;         -- h
      when 16#43# => ascii_o := 16#49#;         -- i
      when 16#3b# => ascii_o := 16#4a#;         -- j
      when 16#42# => ascii_o := 16#4b#;         -- k
      when 16#4b# => ascii_o := 16#4c#;         -- l
      when 16#3a# => ascii_o := 16#4d#;         -- m
      when 16#31# => ascii_o := 16#4e#;         -- n  
      when 16#44# => ascii_o := 16#4f#;         -- o
      when 16#4d# => ascii_o := 16#50#;         -- p
      when 16#15# => ascii_o := 16#51#;         -- q
      when 16#2d# => ascii_o := 16#52#;         -- r
      when 16#1b# => ascii_o := 16#53#;         -- s
      when 16#2c# => ascii_o := 16#54#;         -- t
      when 16#3c# => ascii_o := 16#55#;         -- u
      when 16#2a# => ascii_o := 16#56#;         -- v
      when 16#1d# => ascii_o := 16#57#;         -- w
      when 16#22# => ascii_o := 16#58#;         -- x
      when 16#35# => ascii_o := 16#59#;         -- y
      when 16#1a# => ascii_o := 16#5a#;         -- z
      when others => ascii_o := 16#00#;         -- _
    end case;
    return std_logic_vector(TO_UNSIGNED(ascii_o, 7));
  end function;
end package body;




--*********************************************************************
-- This module accepts a serial datastream and clock from a PS/2 keyboard
-- and outputs the scan code for any key that is pressed and released.
--
--    1. The clock from the PS/2 keyboard does not drive the clock inputs of
--       any of the registers in this circuit.  Instead, it is sampled at the
--       frequency of the main clock input and edges are extracted from the samples.
--       So you have to apply a main clock that is substantially faster than
--       the 10 KHz PS/2 clock.  It should be 200 KHz or more.
--
--    2. The scan code is only valid when the ready signal is high.  The scan code
--       should be registered by an external circuit on the first clock edge
--       after the ready signal goes high.
--
--    3. The ready signal pulses only after the key is released.
--
--    4. The error flag is set whenever the PS/2 clock stops pulsing and the
--       PS/2 clock is either at a low level or less than 11 bits of serial
--       data have been received (start + 8 data + parity + stop).  The circuit
--       locks up once an error is detected and will not resume operation until
--       a reset is applied.
--
--*********************************************************************

library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;
use UNISIM.vcomponents.all;
use work.CommonPckg.all;

entity Ps2KbdScanner is
  generic(
    FREQ_G : real := 100.0              -- Frequency of the main clock (MHz).
    );
  port(
    clk_i      : in  std_logic;         -- Main clock.
    rst_i      : in  std_logic := NO;   -- Asynchronous reset.
    ps2Clk_i   : in  std_logic;         -- Clock from PS/2 keyboard.
    ps2Data_i  : in  std_logic;         -- Serial data from PS/2 keyboard.
    scanCode_o : out std_logic_vector(7 downto 0);  -- PS/2 keyboard scan code.
    rdy_o      : out std_logic := NO;  -- Pulses high when a scan code is ready.
    error_o    : out std_logic := NO  -- Goes high when there is an error receiving scan code.
    );
end entity;


architecture arch of Ps2KbdScanner is
  constant PS2_FREQ_C     : real                          := 10.0;  -- PS/2 keyboard clock frequency (KHz).
  constant QUIET_PERIOD_C : natural                       := integer((FREQ_G * 1000.0) / PS2_FREQ_C);  -- PS/2 clock quiet timeout.
  constant KEY_RELEASE_C  : std_logic_vector(8 downto 1)  := "11110000";  -- scan code sent when key is released.
  signal scanCode_r       : std_logic_vector(10 downto 0) := (others => ONE);
begin

  process(clk_i, rst_i)
    variable ps2ClkShf_v  : std_logic_vector(3 downto 0)          := (others => ONE);
    variable bitCntr_v    : natural range 15 downto 0             := 0;
    variable quietTimer_v : natural range QUIET_PERIOD_C downto 0 := 0;
    variable keyRelease_v : boolean                               := false;
  begin
    if rst_i = YES then                 -- Asynchronous reset.
      error_o      <= NO;               -- Clear any errors.
      rdy_o        <= NO;               -- No scan code is ready.
      ps2ClkShf_v  := (others => ONE);  -- Assume PS/2 clock has been at high level for a while.
      quietTimer_v := QUIET_PERIOD_C;  -- Assume PS/2 clock has been at a high level for a while.
      bitCntr_v    := 0;  -- No PS/2 serial data bits have arrived.
      keyRelease_v := false;            -- No key has been pressed or released.
      
    elsif rising_edge(clk_i) then
      
      rdy_o <= NO;  -- This ensures the ready signal will only be high for one clock cycle after a scan code appears. 

      -- Detect a non-noisy rising or falling edge on the PS/2 clock.
      ps2ClkShf_v := ps2ClkShf_v(2 downto 0) & ps2Clk_i;  -- Store the four most-recent PS/2 clock levels.
      case ps2ClkShf_v(3 downto 0) is  -- Branch based on the pattern of recent PS/2 clock levels.
        when "1100" =>                  -- Falling edge of PS/2 clock signal.
          scanCode_r   <= ps2Data_i & scanCode_r(10 downto 1);  -- Shift data bit into scan code register.
          bitCntr_v    := bitCntr_v + 1;  -- One more bit has been received.
          quietTimer_v := 0;     -- The clock is changing, so reset the timer.
        when "0000" | "1111" =>  -- PS/2 clock is quiet at a constant high or low.
          quietTimer_v := quietTimer_v + 1;
        when others =>  -- PS/2 clock signal is chattering, but we don't care in what manner.
          quietTimer_v := 0;     -- PS/2 clock is changing, so reset the timer.
      end case;

      -- If the PS/2 clock hasn't changed for a while ...
      if quietTimer_v = QUIET_PERIOD_C then
        if ps2Clk_i = LO then     -- The PS/2 clock should not be held low ...
          error_o <= YES;               -- or else it's an error.
        elsif bitCntr_v = 11 then  -- OK, PS/2 clock is high and 11 bits were received ...
          bitCntr_v := 0;  -- Reset the bit counter for the next scan code reception.
          if scanCode_r(0) = ZERO and scanCode_r(10) = ONE then  -- Check the start and stop bits.
            if scanCode_r(8 downto 1) = KEY_RELEASE_C then  -- Is the scan code from the release of a key?
              keyRelease_v := true;  -- Then flag it so we can get the scan code for the released key when it arrives next.
            elsif keyRelease_v = true then  -- The release scan code has already been seen ...
              rdy_o        <= YES;  -- So the scan code for the pressed key is available in the shift register.
              keyRelease_v := false;  -- Clear the flag for the next key press that occurs.
            else  -- A scan code without a preceding release, so this is the scan code that arrives when the key is first pressed.
              keyRelease_v := false;  -- Wait to get the key's scan code until the key is released.
            end if;
          else    -- One or both start/stop bits has the wrong value.
            error_o <= YES;             -- A framing error has occurred.
          end if;
        elsif bitCntr_v = 0 then  -- PS/2 clock is high & stable and no serial data has arrived.
          null;   -- Do nothing. (rdy_o should already be low.)
        else  -- PS/2 clock is high and stable, but the wrong number of data bits have been received.
          error_o <= YES;               -- A framing error has occurred.
        end if;
      end if;

    end if;
  end process;

  scanCode_o(7 downto 0) <= scanCode_r(8 downto 1);  -- 

end architecture;




--*********************************************************************
-- This test design accepts keystrokes from a PS/2 keyboard and displays
-- the keyboard character on LED1 of the LED display.
--*********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.CommonPckg.all;
use work.Ps2KbdPckg.all;
use work.LedDigitsPckg.all;


entity KbdScannerTest is
  generic(
    FREQ_G : real := 12.0               -- Frequency of main clock (MHz).
    );
  port(
    clk_i      : in  std_logic;         -- Main clock.
    ps2ClkA_i  : in  std_logic;         -- PS/2 keyboard clock.
    ps2DataA_i : in  std_logic;         -- PS/2 keyboard serial data.
    s_o        : out std_logic_vector(7 downto 0)
    );
end entity;


architecture arch of KbdScannerTest is

  signal scanCode_s : std_logic_vector(7 downto 0);  -- Scan code from keyboard.
  signal rdy_s      : std_logic;  -- Indicates when scan code is available.
  signal kbdError_s : std_logic;  -- Indicates error when receiving scan code from keyboard.
  signal ascii_s    : std_logic_vector(6 downto 0);  -- ASCII character translation of scan code.

  constant LETTER_E : natural := 16#45#;  -- ASCII code for 'E'.

begin

  u0 : Ps2KbdScanner
    generic map(
      FREQ_G => FREQ_G
      )
    port map(
      clk_i      => clk_i,
      rst_i      => NO,
      ps2Clk_i   => ps2ClkA_i,
      ps2Data_i  => ps2DataA_i,
      scanCode_o => scanCode_s,
      rdy_o      => rdy_s,
      error_o    => kbdError_s
      );

  -- This maps the received scan code into an ASCII character.
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if kbdError_s = YES then
        ascii_s <= std_logic_vector(TO_UNSIGNED(LETTER_E, 7));
      elsif rdy_s = YES then
        ascii_s <= scanCodeToAscii(scanCode_s);
      end if;
    end if;
  end process;

  -- Display the ASCII character on the first digit of the LED display.
  uLeds : LedDigitsDisplay
    generic map(
      FREQ_G => FREQ_G
      )
    port map (
      clk_i        => clk_i,
      ledDigit1_i  => CharToLedDigit(ascii_s),  -- Convert the ASCII into a pattern of LED segments.
      ledDrivers_o => s_o
      );

end architecture;
