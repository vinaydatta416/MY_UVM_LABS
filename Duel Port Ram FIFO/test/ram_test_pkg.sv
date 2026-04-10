
package ram_test_pkg;


	//import uvm_pkg.sv
	
	import uvm_pkg::*;
	
	//include uvm_macros.svh,"tb_defs.sv", "write_xtn.sv"
 
	//"ram_wr_agent_config.sv", "ram_rd_agent_config.sv", "ram_env_config.sv"
 
	//"ram_wr_driver.sv","ram_wr_monitor.sv", "ram_wr_sequencer.sv", "ram_wr_agent.sv"
	//"ram_wr_agt_top.sv", "ram_wr_seqs.sv", "read_xtn.sv", "ram_rd_monitor.sv"
	//"ram_rd_sequencer.sv", "ram_rd_seqs.sv", "ram_rd_driver.sv","ram_rd_agent.sv"
	//"ram_rd_agt_top.sv", "ram_virtual_sequencer.sv", "ram_virtual_seqs.sv",ram_scoreboard.sv"

	//"ram_tb.sv", "ram_vtest_lib.sv"
		
	//include uvm_macros.sv
	`include "uvm_macros.svh"
	`include "tb_defs.sv"
	`include "write_xtn.sv"
	`include "ram_wr_agent_config.sv"
	`include "ram_rd_agent_config.sv"
	`include "ram_env_config.sv"
	`include "ram_wr_driver.sv"
	`include "ram_wr_monitor.sv"
	`include "ram_wr_sequencer.sv"
	`include "ram_wr_agent.sv"
	`include "ram_wr_agt_top.sv"
	`include "ram_wr_seqs.sv"

	`include "read_xtn.sv"
	`include "ram_rd_monitor.sv"
	`include "ram_rd_sequencer.sv"
	`include "ram_rd_seqs.sv"
	`include "ram_rd_driver.sv"
	`include "ram_rd_agent.sv"
	`include "ram_rd_agt_top.sv"

	`include "ram_virtual_sequencer.sv"
	`include "ram_virtual_seqs.sv"
	`include "ram_scoreboard.sv"

	`include "ram_tb.sv"


	`include "ram_vtest_lib.sv"
	
endpackage