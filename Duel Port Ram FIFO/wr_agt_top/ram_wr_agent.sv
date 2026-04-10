

// Extend ram_wr_agent from uvm_agent
class ram_wr_agent extends uvm_agent;

   // Factory Registration
	`uvm_component_utils(ram_wr_agent)

   // Declare handle for configuration object
    ram_wr_agent_config m_cfg;
        
   // Declare handles of ram_wr_monitor,ram_wr_sequencer and ram_wr_driver
   // with Handle names as monh, seqrh, drvh respectively
	ram_wr_monitor monh;
	ram_wr_sequencer seqrh;
	ram_wr_driver drvh;

	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods :
	extern function new(string name = "ram_wr_agent", uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass : ram_wr_agent
//-----------------  constructor new method  -------------------//

function ram_wr_agent::new(string name = "ram_wr_agent", 
                           uvm_component parent = null);
	super.new(name, parent);
endfunction
     
  
//-----------------  build() phase method  -------------------//
// Call parent build phase
// Create ram_wr_monitor instance
// If config parameter is_active=UVM_ACTIVE, create ram_wr_driver and ram_wr_sequencer instances
function void ram_wr_agent::build_phase(uvm_phase phase);

	super.build_phase(phase);
   // get the config object using uvm_config_db
	if(!uvm_config_db #(ram_wr_agent_config)::get(this,"","ram_wr_agent_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
	monh=ram_wr_monitor::type_id::create("monh",this);	
	if(m_cfg.is_active==UVM_ACTIVE)
		begin
			drvh=ram_wr_driver::type_id::create("drvh",this);
			seqrh=ram_wr_sequencer::type_id::create("seqrh",this);
		end
		
endfunction

      
//-----------------  connect() phase method  -------------------//
//If config parameter is_active=UVM_ACTIVE, 
//connect driver(TLM seq_item_port) and sequencer(TLM seq_item_export)

function void ram_wr_agent::connect_phase(uvm_phase phase);
	if(m_cfg.is_active==UVM_ACTIVE)
		begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
  		end
endfunction
   


   


