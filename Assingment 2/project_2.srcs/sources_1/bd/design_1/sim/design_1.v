//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
//Date        : Wed Apr  4 08:32:17 2018
//Host        : DESKTOP-JREG6AA running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (addra,
    clka,
    dina,
    douta,
    wea);
  input [6:0]addra;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLKA CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLKA, CLK_DOMAIN design_1_clka, FREQ_HZ 100000000, PHASE 0.000" *) input clka;
  input [18:0]dina;
  output [18:0]douta;
  input [0:0]wea;

  wire [6:0]addra_1;
  wire [18:0]blk_mem_gen_0_douta;
  wire clka_1;
  wire [18:0]dina_1;
  wire [0:0]wea_1;

  assign addra_1 = addra[6:0];
  assign clka_1 = clka;
  assign dina_1 = dina[18:0];
  assign douta[18:0] = blk_mem_gen_0_douta;
  assign wea_1 = wea[0];
  design_1_blk_mem_gen_0_0 blk_mem_gen_0
       (.addra(addra_1),
        .clka(clka_1),
        .dina(dina_1),
        .douta(blk_mem_gen_0_douta),
        .wea(wea_1));
endmodule
