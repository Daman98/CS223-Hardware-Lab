#!/bin/sh
# Vivado(TM)
# compile.sh: Vivado-generated Script for launching XSim application
# Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
# 
if [ -z "$PATH" ]; then
  PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%:C:/Xilinx/Vivado/2014.1/ids_lite/ISE/bin/nt64;C:/Xilinx/Vivado/2014.1/ids_lite/ISE/lib/nt64
else
  PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%:C:/Xilinx/Vivado/2014.1/ids_lite/ISE/bin/nt64;C:/Xilinx/Vivado/2014.1/ids_lite/ISE/lib/nt64:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=:
else
  LD_LIBRARY_PATH=::$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

#
# Setup env for Xilinx simulation libraries
#
XILINX_PLANAHEAD=C:/Xilinx/Vivado/2014.1
export XILINX_PLANAHEAD
ExecStep()
{
   "$@"
   RETVAL=$?
   if [ $RETVAL -ne 0 ]
   then
       exit $RETVAL
   fi
}
XELAB_1="C:/Users/reliance digiital/HDL_Projects/Assingment3/Assingment3.sim/sim_1/behav/tb1.prj"

ExecStep xelab -m64 --debug typical --relax -L xil_defaultlib -L secureip --snapshot tb1_behav --prj "$XELAB_1"   xil_defaultlib.tb1
