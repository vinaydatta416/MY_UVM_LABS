
 // Extend ram_virtual_sequencer from uvm_sequencer
class ram_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item) ;
   
    // Factory Registration
	`uvm_component_utils(ram_virtual_sequencer)

   // Declare dynamic array of handles for ram_wr_sequencer and ram_rd_sequencer as wr_seqrh[] & rd_seqrh[]

	ram_wr_sequencer wr_seqrh[];
	ram_rd_sequencer rd_seqrh[];

    // Declare handle for ram_env_config 
   	 ram_env_config m_cfg;


	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard OVM Methods:
 	extern function new(string name = "ram_virtual_sequencer",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass

// Define Constructor new() function
function ram_virtual_sequencer::new(string name="ram_virtual_sequencer",uvm_component parent);
	super.new(name,parent);
endfunction

   // function void build
function void ram_virtual_sequencer::build_phase(uvm_phase phase);
	// get the config object using uvm_config_db 
	if(!uvm_config_db #(ram_env_config)::get(this,"","ram_env_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
    super.build_phase(phase);

	// LAB : Create dynamic array handles wr_seqrh & rd_seqrh equal to
	// the config parameter no_of_duts

    wr_seqrh = new[m_cfg.no_of_duts];
    rd_seqrh = new[m_cfg.no_of_duts];
endfunction
