--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:07:20 11/04/2011
-- Design Name:   
-- Module Name:   C:/xesscorp/PRODUCTS/StickIt/modules/Buttons/FPGA/ButtonScanner/ButtonScanner_tb.vhd
-- Project Name:  ButtonScanner
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ButtonScanner
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ButtonScanner_tb IS
END ButtonScanner_tb;
 
ARCHITECTURE behavior OF ButtonScanner_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ButtonScanner
    PORT(
         clk_i : IN  std_logic;
         b_io : INOUT  std_logic_vector(3 downto 0);
         button_o : OUT  std_logic_vector(12 downto 1)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';

	--BiDirs
   signal b_io : std_logic_vector(3 downto 0);

 	--Outputs
   signal button_o : std_logic_vector(12 downto 1);

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ButtonScanner PORT MAP (
          clk_i => clk_i,
          b_io => b_io,
          button_o => button_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 1 ns;	

      --wait for clk_i_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
