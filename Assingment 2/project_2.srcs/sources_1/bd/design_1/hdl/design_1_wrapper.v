//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
//Date        : Wed Apr  4 08:32:17 2018
//Host        : DESKTOP-JREG6AA running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (addra,
    clka,
    dina,
    douta,
    wea);
  input [6:0]addra;
  input clka;
  input [18:0]dina;
  output [18:0]douta;
  input [0:0]wea;

  wire [6:0]addra;
  wire clka;
  wire [18:0]dina;
  wire [18:0]douta;
  wire [0:0]wea;

  design_1 design_1_i
       (.addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .wea(wea));
endmodule
