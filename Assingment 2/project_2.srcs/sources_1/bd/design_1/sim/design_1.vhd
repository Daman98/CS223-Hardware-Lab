--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
--Date        : Wed Apr  4 21:52:14 2018
--Host        : DESKTOP-ATANOJF running 64-bit major release  (build 9200)
--Command     : generate_target design_1.bd
--Design      : design_1
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1 is
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
  attribute core_generation_info : string;
  attribute core_generation_info of design_1 : entity is "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute hw_handoff : string;
  attribute hw_handoff of design_1 : entity is "design_1.hwdef";
end design_1;

architecture STRUCTURE of design_1 is
  component design_1_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 4 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  end component design_1_blk_mem_gen_0_0;
  component design_1_blk_mem_gen_0_1 is
  port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 4 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  end component design_1_blk_mem_gen_0_1;
  component design_1_blk_mem_gen_0_2 is
  port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 4 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  end component design_1_blk_mem_gen_0_2;
  component design_1_blk_mem_gen_0_3 is
  port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 4 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 9 downto 0 )
  );
  end component design_1_blk_mem_gen_0_3;
  signal addra_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal blk_mem_gen_0_douta : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal blk_mem_gen_1_douta : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal blk_mem_gen_2_douta : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal blk_mem_gen_3_douta : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal clka_1 : STD_LOGIC;
  signal dina_1 : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal we2_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal we3_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal we4_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal wea_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute x_interface_info : string;
  attribute x_interface_info of clka : signal is "xilinx.com:signal:clock:1.0 CLK.CLKA CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of clka : signal is "XIL_INTERFACENAME CLK.CLKA, CLK_DOMAIN design_1_clka, FREQ_HZ 100000000, PHASE 0.000";
begin
  addra_1(4 downto 0) <= addra(4 downto 0);
  clka_1 <= clka;
  dina_1(9 downto 0) <= dina(9 downto 0);
  do1(9 downto 0) <= blk_mem_gen_0_douta(9 downto 0);
  do2(9 downto 0) <= blk_mem_gen_3_douta(9 downto 0);
  do3(9 downto 0) <= blk_mem_gen_2_douta(9 downto 0);
  do4(9 downto 0) <= blk_mem_gen_1_douta(9 downto 0);
  we2_1(0) <= we2(0);
  we3_1(0) <= we3(0);
  we4_1(0) <= we4(0);
  wea_1(0) <= we1(0);
blk_mem_gen_0: component design_1_blk_mem_gen_0_0
     port map (
      addra(4 downto 0) => addra_1(4 downto 0),
      clka => clka_1,
      dina(9 downto 0) => dina_1(9 downto 0),
      douta(9 downto 0) => blk_mem_gen_0_douta(9 downto 0),
      wea(0) => wea_1(0)
    );
blk_mem_gen_1: component design_1_blk_mem_gen_0_1
     port map (
      addra(4 downto 0) => addra_1(4 downto 0),
      clka => clka_1,
      dina(9 downto 0) => dina_1(9 downto 0),
      douta(9 downto 0) => blk_mem_gen_1_douta(9 downto 0),
      wea(0) => we4_1(0)
    );
blk_mem_gen_2: component design_1_blk_mem_gen_0_2
     port map (
      addra(4 downto 0) => addra_1(4 downto 0),
      clka => clka_1,
      dina(9 downto 0) => dina_1(9 downto 0),
      douta(9 downto 0) => blk_mem_gen_2_douta(9 downto 0),
      wea(0) => we3_1(0)
    );
blk_mem_gen_3: component design_1_blk_mem_gen_0_3
     port map (
      addra(4 downto 0) => addra_1(4 downto 0),
      clka => clka_1,
      dina(9 downto 0) => dina_1(9 downto 0),
      douta(9 downto 0) => blk_mem_gen_3_douta(9 downto 0),
      wea(0) => we2_1(0)
    );
end STRUCTURE;
