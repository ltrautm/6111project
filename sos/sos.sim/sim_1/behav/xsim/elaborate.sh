#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.1.2 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Mon Dec 09 14:37:02 EST 2019
# SW Build 2615518 on Fri Aug  9 15:53:29 MDT 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xelab -wto ac1623565eff432b9495f10772a76fef --incr --debug typical --relax --mt 8 -L xbip_utils_v3_0_10 -L axi_utils_v2_0_6 -L xbip_pipe_v3_0_6 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_6 -L xbip_dsp48_multadd_v3_0_6 -L xbip_bram18k_v3_0_6 -L mult_gen_v12_0_15 -L floating_point_v7_1_8 -L xil_defaultlib -L blk_mem_gen_v8_4_3 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot distance_tb_behav xil_defaultlib.distance_tb xil_defaultlib.glbl -log elaborate.log"
xelab -wto ac1623565eff432b9495f10772a76fef --incr --debug typical --relax --mt 8 -L xbip_utils_v3_0_10 -L axi_utils_v2_0_6 -L xbip_pipe_v3_0_6 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_6 -L xbip_dsp48_multadd_v3_0_6 -L xbip_bram18k_v3_0_6 -L mult_gen_v12_0_15 -L floating_point_v7_1_8 -L xil_defaultlib -L blk_mem_gen_v8_4_3 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot distance_tb_behav xil_defaultlib.distance_tb xil_defaultlib.glbl -log elaborate.log

