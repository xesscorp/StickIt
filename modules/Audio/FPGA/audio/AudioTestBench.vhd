--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:05:25 07/14/2011
-- Design Name:   
-- Module Name:   C:/xesscorp/PRODUCTS/APPNOTES/app003/FPGA/audio/AudioTestBench.vhd
-- Project Name:  audio
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Audio
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
 
ENTITY AudioTestBench IS
END AudioTestBench;
 
ARCHITECTURE behavior OF AudioTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Audio
    PORT(
         clk_i : IN  std_logic;
         mclk_o : OUT  std_logic;
         sclk_o : OUT  std_logic;
         lrck_o : OUT  std_logic;
         sdti_o : OUT  std_logic;
         sdto_i : IN  std_logic;
         csn_o : OUT  std_logic;
         cclk_o : OUT  std_logic;
         cdti_o : OUT  std_logic;
         adcRdyDiag_o : OUT  std_logic;
         dacRdyDiag_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal sdto_i : std_logic := '0';

 	--Outputs
   signal mclk_o : std_logic;
   signal sclk_o : std_logic;
   signal lrck_o : std_logic;
   signal sdti_o : std_logic;
   signal csn_o : std_logic;
   signal cclk_o : std_logic;
   signal cdti_o : std_logic;
   signal adcRdyDiag_o : std_logic;
   signal dacRdyDiag_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 83.3 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Audio PORT MAP (
          clk_i => clk_i,
          mclk_o => mclk_o,
          sclk_o => sclk_o,
          lrck_o => lrck_o,
          sdti_o => sdti_o,
          sdto_i => sdti_o,
          csn_o => csn_o,
          cclk_o => cclk_o,
          cdti_o => cdti_o,
          adcRdyDiag_o => adcRdyDiag_o,
          dacRdyDiag_o => dacRdyDiag_o
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
