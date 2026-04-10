

// Extend ram_wr_agt_top from uvm_env;
class ram_wr_agt_top extends uvm_env;

   // Factory Registration
	`uvm_component_utils(ram_wr_agt_top)
    
   //Declare the agent handle
    ram_wr_agent agnth;
	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
	extern function new(string name = "ram_wr_agt_top" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	
endclass
//-----------------  constructor new method  -------------------//
// Define Constructor new() function
function ram_wr_agt_top::new(string name = "ram_wr_agt_top" , uvm_component parent);
	super.new(name,parent);
endfunction

    
//-----------------  build() phase method  -------------------//
function void ram_wr_agt_top::build_phase(uvm_phase phase);
    super.build_phase(phase);
	// Create the instance of ram_wr_agent
   	agnth=ram_wr_agent::type_id::create("agnth",this);
endfunction


//-----------------  run() phase method  -------------------//
// Print the topology
task ram_wr_agt_top::run_phase(uvm_phase phase);
	uvm_top.print_topology;
endtask   


