--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:13:51 02/07/2018
-- Design Name:   
-- module Name:   C:/Users/acaimus/aLU2/tb1.vhd
-- Project Name:  aLU2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test bench Created by IsE for module: aLU2
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
UsE ieee.std_logic_1164.aLL;
 UsE ieee.std_logic_unsigned.aLL;
-- Uncomment the following library declaration if using
-- arithmetic functions with signed or Unsigned values
--UsE ieee.numeric_std.aLL;
 
ENTITY tb1 Is
END tb1;
 
aRCHITECTURE behavior OF tb1 Is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COmPONENT aLU2
    PORT(
         a : IN sTD_LOGIC_VECTOR(3 DOWNTO 0);
               b : IN sTD_LOGIC_VECTOR(3 DOWNTO 0);
               s : IN sTD_LOGIC_VECTOR(3 DOWNTO 0);
               m : in sTD_LOGIC;
               cn : in sTD_LOGIC;
               eanb : out sTD_LOGIC;
               cnp4 : out sTD_LOGIC;
               x : out sTD_LOGIC;
               y : out sTD_LOGIC;
               f : OUT sTD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COmPONENT;
    

   --Inputs
   signal a : std_logic_vector(3 downto 0) := (others => '0');
   signal b : std_logic_vector(3 downto 0) := (others => '0');
   signal s : std_logic_vector(3 downto 0) := (others => '0');
   signal cn : std_logic := '0';
   signal m : std_logic := '0';

 	--Outputs
   signal f: std_logic_vector(3 downto 0);
   signal cnp4 : std_logic;
   signal eanb : std_logic;
   signal y : std_logic;
   signal x : std_logic;

   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
 
bEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aLU2 PORT maP (
          a => a,
          b => b,
          s => s,
          cn => cn,
          m => m,
          f => f,
          cnp4 => cnp4,
          x => x,
          y=> y,
          eanb => eanb
        );

   -- Clock process definitions
 

   -- stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		-- insert stimulus here 
		wait for 100 ns;	
		a<="0000";
		b<="0000";
		m<='1';
		s<="0000";
		cn<='0';
      wait for 40 ns;
		a<="0011";
		b<="0101";
		m<='1';
		s<="0001";
		cn<='0';
      wait for 40 ns;
		a<="0011";
		b<="0101";
		m<='1';
		s<="0010";
		cn<='0';
      wait for 40 ns;
		a<="0011";
		b<="0101";
		m<='1';
		s<="0011";
		cn<='0';
      wait for 40 ns;
		a<="0011";
		b<="0101";
		m<='1';
		s<="0100";
		cn<='0';
      wait for 40 ns;
		a<="0011";
		b<="0101";
		m<='1';
		s<="0101";
		cn<='0';
      wait for 40 ns;
		a<="0011";
		b<="0101";
		m<='1';
		s<="0110";
		cn<='0';
      wait for 40 ns;
		a<="0011";
		b<="0101";
		m<='1';
		s<="0111";
		cn<='0';
      wait for 40 ns;
		a<="1111";
		b<="0101";
		m<='0';
		s<="1001";
		cn<='0';
      wait for 40 ns;		
		a<="0011";
		b<="0101";
		m<='0';
		s<="1111";
		cn<='0';
	   wait for 40 ns;		
		a<="1111";
		b<="0001";
		m<='0';
		s<="1111";
		cn<='0';
	   wait for 40 ns;		
		a<="1100";
		b<="0000";
		m<='0';
		s<="0110";
		cn<='0';	
		wait for 40 ns;		
		a<="0000";
		b<="1100";
		m<='0';
		s<="0110";
		cn<='0';	
		wait for 40 ns;		
		a<="0000";
		b<="1111";
		m<='0';
		s<="0110";
		cn<='0';	
      wait;
   end process;

END;
