

// Extend ram_wr_sequencer from uvm_sequencer parameterized by write_xtn
class ram_wr_sequencer extends uvm_sequencer #(write_xtn);

	// Factory registration using `uvm_component_utils
	`uvm_component_utils(ram_wr_sequencer)

	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
	extern function new(string name = "ram_wr_sequencer",uvm_component parent);
endclass

//-----------------  constructor new method  -------------------//
function ram_wr_sequencer::new(string name="ram_wr_sequencer",uvm_component parent);
	super.new(name,parent);
endfunction