--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:51:09 11/04/2011
-- Design Name:   
-- Module Name:   C:/xesscorp/PRODUCTS/StickIt/modules/Buttons/FPGA/ButtonScanner/ButtonScannerTest_tb.vhd
-- Project Name:  ButtonScanner
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ButtonScannerTest
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
 
ENTITY ButtonScannerTest_tb IS
END ButtonScannerTest_tb;
 
ARCHITECTURE behavior OF ButtonScannerTest_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ButtonScannerTest
    PORT(
         clk_i : IN  std_logic;
         b_io : INOUT  std_logic_vector(3 downto 0);
         s_o : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';

	--BiDirs
   signal b_io : std_logic_vector(3 downto 0);

 	--Outputs
   signal s_o : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ButtonScannerTest PORT MAP (
          clk_i => clk_i,
          b_io => b_io,
          s_o => s_o
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
      wait for 100 ns;	

      wait for clk_i_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
