--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
--Date        : Wed Apr  4 21:52:14 2018
--Host        : DESKTOP-ATANOJF running 64-bit major release  (build 9200)
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    addra : in STD_LOGIC_VECTOR ( 4 downto 0 );
    clka : in STD_LOGIC;
    dina : in STD_LOGIC_VECTOR ( 9 downto 0 );
    do1 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    do2 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    do3 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    do4 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    we1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    we2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    we3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    we4 : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    clka : in STD_LOGIC;
    dina : in STD_LOGIC_VECTOR ( 9 downto 0 );
    do2 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    do3 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    do4 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    do1 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    we2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    we3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    we4 : in STD_LOGIC_VECTOR ( 0 to 0 );
    we1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 4 downto 0 )
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      addra(4 downto 0) => addra(4 downto 0),
      clka => clka,
      dina(9 downto 0) => dina(9 downto 0),
      do1(9 downto 0) => do1(9 downto 0),
      do2(9 downto 0) => do2(9 downto 0),
      do3(9 downto 0) => do3(9 downto 0),
      do4(9 downto 0) => do4(9 downto 0),
      we1(0) => we1(0),
      we2(0) => we2(0),
      we3(0) => we3(0),
      we4(0) => we4(0)
    );
end STRUCTURE;
