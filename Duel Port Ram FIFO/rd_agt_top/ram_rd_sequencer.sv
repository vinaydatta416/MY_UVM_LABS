

// Extend ram_rd_sequencer from uvm_sequencer parameterized by read_xtn
class ram_rd_sequencer extends uvm_sequencer #(read_xtn);

	// Factory registration using `uvm_component_utils
	`uvm_component_utils(ram_rd_sequencer)

	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
	extern function new(string name = "ram_rd_sequencer",uvm_component parent);
endclass
//-----------------  constructor new method  -------------------//

function ram_rd_sequencer::new(string name="ram_rd_sequencer",uvm_component parent);
	super.new(name,parent);
endfunction

  









