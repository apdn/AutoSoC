`include "dbg_config.vh"
module system_noc
(
input clk,
input rst_sys,

output[4 * 32 - 1:0] wb_ext_adr_i,
output[4 * 1 - 1:0] wb_ext_cyc_i,
output[4 * 32 - 1:0] wb_ext_dat_i,
output[4 * 4 - 1:0] wb_ext_sel_i,
output[4 * 1 - 1:0] wb_ext_stb_i,
output[4 * 1 - 1:0] wb_ext_we_i,
output[4 * 1 - 1:0] wb_ext_cab_i,
output[4 * 3 - 1:0] wb_ext_cti_i,
output[4 * 2 - 1:0] wb_ext_bte_i,
input[4 * 1 - 1:0] wb_ext_ack_o,
input[4 * 1 - 1:0] wb_ext_rty_o,
input[4 * 1 - 1:0] wb_ext_err_o,
input[4 * 32 - 1:0] wb_ext_dat_o
);


import dii_package::dii_flit;
import optimsoc_functions::*;
import opensocdebug::mor1kx_trace_exec;
import optimsoc_config::*;

parameter config_t CONFIG = 'x; 
localparam FLIT_WIDTH = CONFIG.NOC_FLIT_WIDTH; 
localparam CHANNELS = CONFIG.NOC_CHANNELS; 
localparam VCHANNELS = 2;
logic rst_cpu;



dii_flit [1:0] debug_ring_in [0:3];
dii_flit [1:0] debug_ring_out [0:3];
logic [1:0] debug_ring_in_ready [0:3];
logic [1:0] debug_ring_out_ready [0:3];
   
/*  debug_interface
      #(
         .SYSTEM_VENDOR_ID (2),
         .SYSTEM_DEVICE_ID (2),
         .NUM_MODULES (CONFIG.DEBUG_NUM_MODS),
         .MAX_PKT_LEN(CONFIG.DEBUG_MAX_PKT_LEN),
         .SUBNET_BITS(CONFIG.DEBUG_SUBNET_BITS),
         .LOCAL_SUBNET(CONFIG.DEBUG_LOCAL_SUBNET),
         .DEBUG_ROUTER_BUFFER_SIZE(CONFIG.DEBUG_ROUTER_BUFFER_SIZE)
      )
      u_debuginterface
        (
         .clk            (clk),
         .rst            (rst),
         .sys_rst        (rst_sys),
         .cpu_rst        (rst_cpu),
         //.glip_in        (c_glip_in),
         //.glip_out       (c_glip_out),
         .ring_out       (debug_ring_in[0]),
         .ring_out_ready (debug_ring_in_ready[0]),
         .ring_in        (debug_ring_out[2]),
         .ring_in_ready  (debug_ring_out_ready[2])
      );

   // We are routing the debug in a meander
   assign debug_ring_in[1] = debug_ring_out[0];
   assign debug_ring_out_ready[0] = debug_ring_in_ready[1];
   assign debug_ring_in[3] = debug_ring_out[1];
   assign debug_ring_out_ready[1] = debug_ring_in_ready[3];
   assign debug_ring_in[2] = debug_ring_out[3];
   assign debug_ring_out_ready[3] = debug_ring_in_ready[2];*/



wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_1_EP;
wire [3:0][CHANNELS-1:0]noc_in_last_R_1_EP;
wire [3:0][CHANNELS-1:0]noc_in_valid_R_1_EP;
wire [3:0][CHANNELS-1:0]noc_out_ready_R_1_EP;
wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_1_EP;
wire [3:0][CHANNELS-1:0]noc_out_last_R_1_EP;
wire [3:0][CHANNELS-1:0]noc_out_valid_R_1_EP;
wire [3:0][CHANNELS-1:0]noc_in_ready_R_1_EP;


cpusubsys1
#(.CONFIG(CONFIG),
.ID(1),
.COREBASE(1*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (1*CONFIG.DEBUG_MODS_PER_TILE)))

cpusubsys1inst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_1_EP[1]),
.noc_in_last (noc_in_last_R_1_EP[1]),
.noc_in_valid (noc_in_valid_R_1_EP[1]),
.noc_out_ready (noc_out_ready_R_1_EP[1]),
.noc_in_ready (noc_in_ready_R_1_EP[1]),
.noc_out_flit (noc_out_flit_R_1_EP[1]),
.noc_out_last (noc_out_last_R_1_EP[1]),
.noc_out_valid (noc_out_valid_R_1_EP[1]));

wire [FLIT_WIDTH-1:0]in_flit_R_1_3;
wire in_last_R_1_2;
wire [VCHANNELS-1:0]in_valid_R_1_3;
wire [VCHANNELS-1:0]out_ready_R_1_3;
wire [VCHANNELS-1:0]in_ready_R_1_3;
wire [FLIT_WIDTH-1:0]out_flit_R_1_3;
wire out_last_R_1_3;
wire [VCHANNELS-1:0]out_valid_R_1_3;

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))

noc_router_R_1_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_1_EP[1],in_flit_R_1_3}),
.in_last ({noc_out_last_R_1_EP[1],in_last_R_1_3}),
.in_valid ({noc_out_valid_R_1_EP[1],in_valid_R_1_3}),
.out_ready ({noc_in_ready_R_1_EP[1],out_ready_R_1_3}),
.out_flit ({noc_in_flit_R_1_EP[1],out_flit_R_1_3}),
.out_last ({noc_in_last_R_1_EP[1],out_last_R_1_3}),
.out_valid ({noc_in_valid_R_1_EP[1],out_valid_R_1_3}),
.in_ready ({noc_out_ready_R_1_EP[1],in_ready_R_1_3}));

wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_2_EP;
wire [3:0][CHANNELS-1:0]noc_in_last_R_2_EP;
wire [3:0][CHANNELS-1:0]noc_in_valid_R_2_EP;
wire [3:0][CHANNELS-1:0]noc_out_ready_R_2_EP;
wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_2_EP;
wire [3:0][CHANNELS-1:0]noc_out_last_R_2_EP;
wire [3:0][CHANNELS-1:0]noc_out_valid_R_2_EP;
wire [3:0][CHANNELS-1:0]noc_in_ready_R_2_EP;


cpusubsys2
#(.CONFIG(CONFIG),
.ID(2),
.COREBASE(1*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (1*CONFIG.DEBUG_MODS_PER_TILE)))

cpusubsys2inst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_2_EP[1]),
.noc_in_last (noc_in_last_R_2_EP[1]),
.noc_in_valid (noc_in_valid_R_2_EP[1]),
.noc_out_ready (noc_out_ready_R_2_EP[1]),
.noc_in_ready (noc_in_ready_R_2_EP[1]),
.noc_out_flit (noc_out_flit_R_2_EP[1]),
.noc_out_last (noc_out_last_R_2_EP[1]),
.noc_out_valid (noc_out_valid_R_2_EP[1]));

wire [FLIT_WIDTH-1:0]in_flit_R_2_3;
wire in_last_R_2_3;
wire [VCHANNELS-1:0]in_valid_R_2_3;
wire [VCHANNELS-1:0]out_ready_R_2_3;
wire [VCHANNELS-1:0]in_ready_R_2_3;
wire [FLIT_WIDTH-1:0]out_flit_R_2_3;
wire out_last_R_2_3;
wire [VCHANNELS-1:0]out_valid_R_2_3;

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))

noc_router_R_2_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_2_EP[1],in_flit_R_2_3}),
.in_last ({noc_out_last_R_2_EP[1],in_last_R_2_3}),
.in_valid ({noc_out_valid_R_2_EP[1],in_valid_R_2_3}),
.out_ready ({noc_in_ready_R_2_EP[1],out_ready_R_2_3}),
.out_flit ({noc_in_flit_R_2_EP[1],out_flit_R_2_3}),
.out_last ({noc_in_last_R_2_EP[1],out_last_R_2_3}),
.out_valid ({noc_in_valid_R_2_EP[1],out_valid_R_2_3}),
.in_ready ({noc_out_ready_R_2_EP[1],in_ready_R_2_3}));



wire [FLIT_WIDTH-1:0]in_flit_R_3_4;
wire in_last_R_3_4;
wire [VCHANNELS-1:0]in_valid_R_3_4;
wire [VCHANNELS-1:0]out_ready_R_3_4;
wire [VCHANNELS-1:0]in_ready_R_3_4;
wire [FLIT_WIDTH-1:0]out_flit_R_3_4;
wire out_last_R_3_4;
wire [VCHANNELS-1:0]out_valid_R_3_4;

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (6),
.OUTPUTS (6),
.DESTS (32))

noc_router_R_3_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({out_flit_R_1_3,out_flit_R_2_3,in_flit_R_3_4}),
.in_last ({out_last_R_1_3,out_last_R_2_3,in_last_R_3_4}),
.in_valid ({out_valid_R_1_3,out_valid_R_2_3,in_valid_R_3_4}),
.out_ready ({in_ready_R_1_3,in_ready_R_2_3,out_ready_R_3_4}),
.out_flit ({in_flit_R_1_3,in_flit_R_2_3,out_flit_R_3_4}),
.out_last ({in_last_R_1_3,in_last_R_2_3,out_last_R_3_4}),
.out_valid ({in_valid_R_1_3,in_valid_R_2_3,out_valid_R_3_4}),
.in_ready ({out_ready_R_1_3,out_ready_R_2_3,in_ready_R_3_4}));
////////////////////////////////////////////////////////////////
wire [FLIT_WIDTH-1:0]in_flit_R_6_4;
wire in_last_R_6_4;
wire [VCHANNELS-1:0]in_valid_R_6_4;
wire [VCHANNELS-1:0]out_ready_R_6_4;
wire [VCHANNELS-1:0]in_ready_R_6_4;
wire [FLIT_WIDTH-1:0]out_flit_R_6_4;
wire out_last_R_6_4;
wire [VCHANNELS-1:0]out_valid_R_6_4;

wire [FLIT_WIDTH-1:0]in_flit_R_5_4;
wire in_last_R_5_4;
wire [VCHANNELS-1:0]in_valid_R_5_4;
wire [VCHANNELS-1:0]out_ready_R_5_4;
wire [VCHANNELS-1:0]in_ready_R_5_4;
wire [FLIT_WIDTH-1:0]out_flit_R_5_4;
wire out_last_R_5_4;
wire [VCHANNELS-1:0]out_valid_R_5_4;

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (6),
.OUTPUTS (6),
.DESTS (32))

noc_router_R_4_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({out_flit_R_3_4,in_flit_R_7_4,out_flit_R_5_4}),
.in_last ({out_last_R_3_4,in_last_R_7_4,out_last_R_5_4}),
.in_valid ({out_valid_R_3_4,out_valid_R_7_4,out_valid_R_5_4}),
.out_ready ({in_ready_R_3_4,in_ready_R_7_4,in_ready_R_5_4}),
.out_flit ({in_flit_R_3_4,in_flit_R_7_4,in_flit_R_5_4}),
.out_last ({in_last_R_3_4,in_last_R_7_4,in_last_R_5_4}),
.out_valid ({in_valid_R_3_4,in_valid_R_7_4,in_valid_R_5_4}),
.in_ready ({out_ready_R_3_4,out_ready_R_7_4,out_ready_R_5_4}));




noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (6),
.OUTPUTS (6),
.DESTS (32))

noc_router_R_5_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({out_flit_R_6_5,in_flit_R_6_4,in_flit_R_5_4}),
.in_last ({out_last_R_6_5,in_last_R_6_4,in_last_R_5_4}),
.in_valid ({out_valid_R_6_5,out_valid_R_6_4,in_valid_R_5_4}),
.out_ready ({in_ready_R_6_5,in_ready_R_6_4,out_ready_R_5_4}),
.out_flit ({in_flit_R_6_5,in_flit_R_6_4,out_flit_R_5_4}),
.out_last ({in_last_R_6_5,in_last_R_6_4,out_last_R_5_4}),
.out_valid ({in_valid_R_6_5,in_valid_R_6_4,out_valid_R_5_4}),
.in_ready ({out_ready_R_6_5,out_ready_R_6_4,in_ready_R_5_4}));

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (6),
.OUTPUTS (6),
.DESTS (32))

noc_router_R_6_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_6_EP[1],in_flit_R_6_5}),
.in_last ({noc_out_last_R_6_EP[1],in_last_R_6_5}),
.in_valid ({noc_out_valid_R_6_EP[1],in_valid_R_6_5}),
.out_ready ({noc_in_ready_R_6_EP[1],out_ready_R_6_5}),
.out_flit ({noc_in_flit_R_6_EP[1],out_flit_R_6_5}),
.out_last ({noc_in_last_R_6_EP[1],out_last_R_6_5}),
.out_valid ({noc_in_valid_R_6_EP[1],out_valid_R_6_5}),
.in_ready ({noc_out_ready_R_6_EP[1],in_ready_R_6_5}));


wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_6_EP;
wire [3:0][CHANNELS-1:0]noc_in_last_R_6_EP;
wire [3:0][CHANNELS-1:0]noc_in_valid_R_6_EP;
wire [3:0][CHANNELS-1:0]noc_out_ready_R_6_EP;
wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_6_EP;
wire [3:0][CHANNELS-1:0]noc_out_last_R_6_EP;
wire [3:0][CHANNELS-1:0]noc_out_valid_R_6_EP;
wire [3:0][CHANNELS-1:0]noc_in_ready_R_6_EP;


memsubsys
#(.CONFIG(CONFIG),
.ID(5),
.COREBASE(5*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (5*CONFIG.DEBUG_MODS_PER_TILE)))

memsubsysinst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_6_EP[1]),
.noc_in_last (noc_in_last_R_6_EP[1]),
.noc_in_valid (noc_in_valid_R_6_EP[1]),
.noc_out_ready (noc_out_ready_R_6_EP[1]),
.noc_in_ready (noc_in_ready_R_6_EP[1]),
.noc_out_flit (noc_out_flit_R_6_EP[1]),
.noc_out_last (noc_out_last_R_6_EP[1]),
.noc_out_valid (noc_out_valid_R_6_EP[1]));

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (6),
.OUTPUTS (6),
.DESTS (32))
noc_router_R_7_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({out_flit_R_7_4,in_flit_R_7_8,out_flit_R_7_11}),
.in_last ({out_last_R_7_4,in_last_R_7_8,out_last_R_7_11}),
.in_valid ({out_valid_R_7_4,out_valid_R_7_8,out_valid_R_7_11}),
.out_ready ({in_ready_R_7_4,in_ready_R_7_8,in_ready_R_7_11}),
.out_flit ({in_flit_R_7_4,in_flit_R_7_8,in_flit_R_7_11}),
.out_last ({in_last_R_7_4,in_last_R_7_8,in_last_R_7_11}),
.out_valid ({in_valid_R_7_4,in_valid_R_7_8,in_valid_R_7_11}),
.in_ready ({out_ready_R_7_4,out_ready_R_7_8,out_ready_R_7_11}));








noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (6),
.OUTPUTS (6),
.DESTS (32))

noc_router_R_8_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({out_flit_R_9_8,out_flit_R_10_8,out_flit_R_7_8}),
.in_last ({out_last_R_9_8,out_last_R_10_8,out_last_R_7_8}),
.in_valid ({out_valid_R_9_8,out_valid_R_10_8,out_valid_R_7_8}),
.out_ready ({in_ready_R_9_8,in_ready_R_10_8,in_ready_R_7_8}),
.out_flit ({in_flit_R_9_8,in_flit_R_10_8,in_flit_R_7_8}),
.out_last ({in_last_R_9_8,in_last_R_10_8,in_last_R_7_8}),
.out_valid ({in_valid_R_9_8,in_valid_R_10_8,in_valid_R_7_8}),
.in_ready ({out_ready_R_9_8,out_ready_R_10_8,out_ready_R_7_8}));

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))

noc_router_R_9_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_9_EP[1],in_flit_R_9_8}),
.in_last ({noc_out_last_R_9_EP[1],in_last_R_9_8}),
.in_valid ({noc_out_valid_R_9_EP[1],in_valid_R_9_8}),
.out_ready ({noc_in_ready_R_9_EP[1],out_ready_R_9_8}),
.out_flit ({noc_in_flit_R_9_EP[1],out_flit_R_9_8}),
.out_last ({noc_in_last_R_9_EP[1],out_last_R_9_8}),
.out_valid ({noc_in_valid_R_9_EP[1],out_valid_R_9_8}),
.in_ready ({noc_out_ready_R_9_EP[1],in_ready_R_9_8}));


noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))

noc_router_R_10_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_10_EP[1],in_flit_R_10_8}),
.in_last ({noc_out_last_R_10_EP[1],in_last_R_10_8}),
.in_valid ({noc_out_valid_R_10_EP[1],in_valid_R_10_8}),
.out_ready ({noc_in_ready_R_10_EP[1],out_ready_R_10_8}),
.out_flit ({noc_in_flit_R_10_EP[1],out_flit_R_10_8}),
.out_last ({noc_in_last_R_10_EP[1],out_last_R_10_8}),
.out_valid ({noc_in_valid_R_10_EP[1],out_valid_R_10_8}),
.in_ready ({noc_out_ready_R_10_EP[1],in_ready_R_10_8}));

wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_9_EP;
wire [3:0][CHANNELS-1:0]noc_in_last_R_9_EP;
wire [3:0][CHANNELS-1:0]noc_in_valid_R_9_EP;
wire [3:0][CHANNELS-1:0]noc_out_ready_R_9_EP;
wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_9_EP;
wire [3:0][CHANNELS-1:0]noc_out_last_R_9_EP;
wire [3:0][CHANNELS-1:0]noc_out_valid_R_9_EP;
wire [3:0][CHANNELS-1:0]noc_in_ready_R_9_EP;

wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_10_EP;
wire [3:0][CHANNELS-1:0]noc_in_last_R_10_EP;
wire [3:0][CHANNELS-1:0]noc_in_valid_R_10_EP;
wire [3:0][CHANNELS-1:0]noc_out_ready_R_10_EP;
wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_10_EP;
wire [3:0][CHANNELS-1:0]noc_out_last_R_10_EP;
wire [3:0][CHANNELS-1:0]noc_out_valid_R_10_EP;
wire [3:0][CHANNELS-1:0]noc_in_ready_R_10_EP;

dspsubsys1
#(.CONFIG(CONFIG),
.ID(2),
.COREBASE(2*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (2*CONFIG.DEBUG_MODS_PER_TILE)))

dspsubsys1inst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_9_EP[1]),
.noc_in_last (noc_in_last_R_9_EP[1]),
.noc_in_valid (noc_in_valid_R_9_EP[1]),
.noc_out_ready (noc_out_ready_R_9_EP[1]),
.noc_in_ready (noc_in_ready_R_9_EP[1]),
.noc_out_flit (noc_out_flit_R_9_EP[1]),
.noc_out_last (noc_out_last_R_9_EP[1]),
.noc_out_valid (noc_out_valid_R_9_EP[1]));



dspsubsys2
#(.CONFIG(CONFIG),
.ID(4),
.COREBASE(4*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (4*CONFIG.DEBUG_MODS_PER_TILE)))

dspsubsys2inst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_10_EP[1]),
.noc_in_last (noc_in_last_R_10_EP[1]),
.noc_in_valid (noc_in_valid_R_10_EP[1]),
.noc_out_ready (noc_out_ready_R_10_EP[1]),
.noc_in_ready (noc_in_ready_R_10_EP[1]),
.noc_out_flit (noc_out_flit_R_10_EP[1]),
.noc_out_last (noc_out_last_R_10_EP[1]),
.noc_out_valid (noc_out_valid_R_10_EP[1]));

//////////////////////////////////////////////////////////
wire [FLIT_WIDTH-1:0]in_flit_R_1_2;
wire in_last_R_1_2;
wire [VCHANNELS-1:0]in_valid_R_1_2;
wire [VCHANNELS-1:0]out_ready_R_1_2;
wire [VCHANNELS-1:0]in_ready_R_1_2;
wire [FLIT_WIDTH-1:0]out_flit_R_1_2;
wire out_last_R_1_2;
wire [VCHANNELS-1:0]out_valid_R_1_2;




wire [1:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_2_EP;
wire [1:0][CHANNELS-1:0]noc_in_last_R_2_EP;
wire [1:0][CHANNELS-1:0]noc_in_valid_R_2_EP;
wire [1:0][CHANNELS-1:0]noc_out_ready_R_2_EP;
wire [1:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_2_EP;
wire [1:0][CHANNELS-1:0]noc_out_last_R_2_EP;
wire [1:0][CHANNELS-1:0]noc_out_valid_R_2_EP;
wire [1:0][CHANNELS-1:0]noc_in_ready_R_2_EP;







wire [FLIT_WIDTH-1:0]in_flit_R_2_3;
wire in_last_R_2_3;
wire [VCHANNELS-1:0]in_valid_R_2_3;
wire [VCHANNELS-1:0]out_ready_R_2_3;
wire [VCHANNELS-1:0]in_ready_R_2_3;
wire [FLIT_WIDTH-1:0]out_flit_R_2_3;
wire out_last_R_2_3;
wire [VCHANNELS-1:0]out_valid_R_2_3;




wire [0:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_13_EP;
wire [0:0][CHANNELS-1:0]noc_in_last_R_13_EP;
wire [0:0][CHANNELS-1:0]noc_in_valid_R_13_EP;
wire [0:0][CHANNELS-1:0]noc_out_ready_R_13_EP;
wire [0:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_13_EP;
wire [0:0][CHANNELS-1:0]noc_out_last_R_13_EP;
wire [0:0][CHANNELS-1:0]noc_out_valid_R_13_EP;
wire [0:0][CHANNELS-1:0]noc_in_ready_R_13_EP;




wire [FLIT_WIDTH-1:0]in_flit_R_3_4;
wire in_last_R_3_4;
wire [VCHANNELS-1:0]in_valid_R_3_4;
wire [VCHANNELS-1:0]out_ready_R_3_4;
wire [VCHANNELS-1:0]in_ready_R_3_4;
wire [FLIT_WIDTH-1:0]out_flit_R_3_4;
wire out_last_R_3_4;
wire [VCHANNELS-1:0]out_valid_R_3_4;
wire [FLIT_WIDTH-1:0]in_flit_R_3_5;
wire in_last_R_3_5;
wire [VCHANNELS-1:0]in_valid_R_3_5;
wire [VCHANNELS-1:0]out_ready_R_3_5;
wire [VCHANNELS-1:0]in_ready_R_3_5;
wire [FLIT_WIDTH-1:0]out_flit_R_3_5;
wire out_last_R_3_5;
wire [VCHANNELS-1:0]out_valid_R_3_5;




//////////////////////////////////////////////////////////
noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))
noc_router_R_11_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({out_flit_R_11_12,in_flit_R_7_11,out_flit_R_11_16}),
.in_last ({out_last_R_11_12,in_last_R_7_11,out_last_R_11_16}),
.in_valid ({out_valid_R_11_12,out_valid_R_7_11,out_valid_R_11_16}),
.out_ready ({in_ready_R_11_12,in_ready_R_7_11,in_ready_R_11_16}),
.out_flit ({in_flit_R_11_12,in_flit_R_7_11,in_flit_R_11_16}),
.out_last ({in_last_R_11_12,in_last_R_7_11,in_last_R_11_16}),
.out_valid ({in_valid_R_11_12,in_valid_R_7_11,in_valid_R_11_16}),
.in_ready ({out_ready_R_11_12,out_ready_R_7_11,out_ready_R_11_16}));



noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))
noc_router_R_12_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({in_flit_R_11_12,in_flit_R_12_13}),
.in_last ({in_last_R_11_12,in_last_R_12_13}),
.in_valid ({in_valid_R_11_12,in_valid_R_12_13}),
.out_ready ({out_ready_R_11_12,out_ready_R_12_13}),
.out_flit ({out_flit_R_11_12,out_flit_R_12_13}),
.out_last ({out_last_R_11_12,out_last_R_12_13}),
.out_valid ({out_valid_R_11_12,out_valid_R_12_13}),
.in_ready ({in_ready_R_11_12,in_ready_R_12_13}));

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))
noc_router_R_13_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({in_flit_R_14_13,in_flit_R_15_13,out_flit_R_12_13}),
.in_last ({in_last_R_14_13,in_last_R_15_13,out_last_R_12_13}),
.in_valid ({in_valid_R_14_13,in_valid_R_15_13,out_valid_R_12_13}),
.out_ready ({out_ready_R_14_13,out_ready_R_15_13,in_ready_R_12_13}),
.out_flit ({out_flit_R_14_13,out_flit_R_15_13,in_flit_R_12_13}),
.out_last ({out_last_R_14_13,out_last_R_15_13,in_last_R_12_13}),
.out_valid ({out_valid_R_14_13,out_valid_R_15_13,in_valid_R_12_13}),
.in_ready ({in_ready_R_14_13,in_ready_R_15_13,out_ready_R_12_13}));


wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_14_EP;
wire [3:0][CHANNELS-1:0]noc_in_last_R_14_EP;
wire [3:0][CHANNELS-1:0]noc_in_valid_R_14_EP;
wire [3:0][CHANNELS-1:0]noc_out_ready_R_14_EP;
wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_14_EP;
wire [3:0][CHANNELS-1:0]noc_out_last_R_14_EP;
wire [3:0][CHANNELS-1:0]noc_out_valid_R_14_EP;
wire [3:0][CHANNELS-1:0]noc_in_ready_R_14_EP;


wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_15_EP;
wire [3:0][CHANNELS-1:0]noc_in_last_R_15_EP;
wire [3:0][CHANNELS-1:0]noc_in_valid_R_15_EP;
wire [3:0][CHANNELS-1:0]noc_out_ready_R_15_EP;
wire [3:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_15_EP;
wire [3:0][CHANNELS-1:0]noc_out_last_R_15_EP;
wire [3:0][CHANNELS-1:0]noc_out_valid_R_15_EP;
wire [3:0][CHANNELS-1:0]noc_in_ready_R_15_EP;



cryptosubsys1
#(.CONFIG(CONFIG),
.ID(8),
.COREBASE(8*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (8*CONFIG.DEBUG_MODS_PER_TILE)))

cryptosubsys1inst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_14_EP[1]),
.noc_in_last (noc_in_last_R_14_EP[1]),
.noc_in_valid (noc_in_valid_R_14_EP[1]),
.noc_out_ready (noc_out_ready_R_14_EP[1]),
.noc_in_ready (noc_in_ready_R_14_EP[1]),
.noc_out_flit (noc_out_flit_R_14_EP[1]),
.noc_out_last (noc_out_last_R_14_EP[1]),
.noc_out_valid (noc_out_valid_R_14_EP[1]));

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))

noc_router_R_14_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_14_EP[1],out_flit_R_14_13}),
.in_last ({noc_out_last_R_14_EP[1],out_last_R_14_13}),
.in_valid ({noc_out_valid_R_14_EP[1],out_valid_R_14_13}),
.out_ready ({noc_in_ready_R_14_EP[1],in_ready_R_14_13}),
.out_flit ({noc_in_flit_R_14_EP[1],in_flit_R_14_13}),
.out_last ({noc_in_last_R_14_EP[1],in_last_R_14_13}),
.out_valid ({noc_in_valid_R_14_EP[1],in_valid_R_14_13}),
.in_ready ({noc_out_ready_R_14_EP[1],out_ready_R_14_13}));


cryptosubsys2
#(.CONFIG(CONFIG),
.ID(9),
.COREBASE(9*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (9*CONFIG.DEBUG_MODS_PER_TILE)))

cryptosubsys2inst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_15_EP[1]),
.noc_in_last (noc_in_last_R_15_EP[1]),
.noc_in_valid (noc_in_valid_R_15_EP[1]),
.noc_out_ready (noc_out_ready_R_15_EP[1]),
.noc_in_ready (noc_in_ready_R_15_EP[1]),
.noc_out_flit (noc_out_flit_R_15_EP[1]),
.noc_out_last (noc_out_last_R_15_EP[1]),
.noc_out_valid (noc_out_valid_R_15_EP[1]));

noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))

noc_router_R_15_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_15_EP[1],out_flit_R_15_13}),
.in_last ({noc_out_last_R_15_EP[1],out_last_R_15_13}),
.in_valid ({noc_out_valid_R_15_EP[1],out_valid_R_15_13}),
.out_ready ({noc_in_ready_R_15_EP[1],in_ready_R_15_13}),
.out_flit ({noc_in_flit_R_15_EP[1],in_flit_R_15_13}),
.out_last ({noc_in_last_R_15_EP[1],in_last_R_15_13}),
.out_valid ({noc_in_valid_R_15_EP[1],in_valid_R_15_13}),
.in_ready ({noc_out_ready_R_15_EP[1],out_ready_R_15_13}));




wire [4:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_in_flit_R_16_EP;
wire [4:0][CHANNELS-1:0]noc_in_last_R_16_EP;
wire [4:0][CHANNELS-1:0]noc_in_valid_R_16_EP;
wire [4:0][CHANNELS-1:0]noc_out_ready_R_16_EP;
wire [4:0][CHANNELS-1:0][FLIT_WIDTH-1:0]noc_out_flit_R_16_EP;
wire [4:0][CHANNELS-1:0]noc_out_last_R_16_EP;
wire [4:0][CHANNELS-1:0]noc_out_valid_R_16_EP;
wire [4:0][CHANNELS-1:0]noc_in_ready_R_16_EP;


wire [FLIT_WIDTH-1:0]in_flit_R_11_16;
wire in_last_R_11_16;
wire [VCHANNELS-1:0]in_valid_R_11_16;
wire [VCHANNELS-1:0]out_ready_R_11_16;
wire [VCHANNELS-1:0]in_ready_R_11_16;
wire [FLIT_WIDTH-1:0]out_flit_R_11_16;
wire out_last_R_11_16;
wire [VCHANNELS-1:0]out_valid_R_11_16;



wire [FLIT_WIDTH-1:0]in_flit_R_17_16;
wire in_last_R_17_16;
wire [VCHANNELS-1:0]in_valid_R_17_16;
wire [VCHANNELS-1:0]out_ready_R_17_16;
wire [VCHANNELS-1:0]in_ready_R_17_16;
wire [FLIT_WIDTH-1:0]out_flit_R_17_16;
wire out_last_R_17_16;
wire [VCHANNELS-1:0]out_valid_R_17_16;



noc_router
#(.VCHANNELS (CHANNELS),
.INPUTS (5),
.OUTPUTS (5),
.DESTS (32))
noc_router_R_16_inst(
.clk (clk),
.rst (rst_sys),
.in_flit ({noc_out_flit_R_16_EP[1],in_flit_R_11_16}),
.in_last ({noc_out_last_R_16_EP[1],in_last_R_11_16}),
.in_valid ({noc_out_valid_R_16_EP[1],in_valid_R_11_16}),
.out_ready ({noc_in_ready_R_16_EP[1],out_ready_R_11_16}),
.out_flit ({noc_in_flit_R_16_EP[1],out_flit_R_11_16}),
.out_last ({noc_in_last_R_16_EP[1],out_last_R_11_16}),
.out_valid ({noc_in_valid_R_16_EP[1],out_valid_R_11_16}),
.in_ready ({noc_out_ready_R_16_EP[1],in_ready_R_11_16}));



connsubsys1
#(.CONFIG(CONFIG),
.ID(11),
.COREBASE(11*CONFIG.CORES_PER_TILE),
.DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS))+ 1 + (11*CONFIG.DEBUG_MODS_PER_TILE)))

connsubsys1inst(
.clk (clk),
.rst_cpu (rst_cpu),
.rst_sys (rst_sys),
.noc_in_flit (noc_in_flit_R_16_EP[1]),
.noc_in_last (noc_in_last_R_16_EP[1]),
.noc_in_valid (noc_in_valid_R_16_EP[1]),
.noc_out_ready (noc_out_ready_R_16_EP[1]),
.noc_in_ready (noc_in_ready_R_16_EP[1]),
.noc_out_flit (noc_out_flit_R_16_EP[1]),
.noc_out_last (noc_out_last_R_16_EP[1]),
.noc_out_valid (noc_out_valid_R_16_EP[1]));



endmodule
