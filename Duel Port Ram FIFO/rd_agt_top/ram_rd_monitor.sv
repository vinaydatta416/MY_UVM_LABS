
// Extend ram_rd_monitor from uvm_monitor
class ram_rd_monitor extends uvm_monitor;

	// Factory Registration
	`uvm_component_utils(ram_rd_monitor)

	// Declare virtual interface handle with RMON_MP as modport
   	virtual ram_if.RMON_MP vif;

	// Declare the ram_rd_agent_config handle as "m_cfg"
    ram_rd_agent_config m_cfg;

	// Analysis TLM port to connect the monitor to the scoreboard for lab09
	uvm_analysis_port #(read_xtn) monitor_port;

	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
	extern function new(string name = "ram_rd_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern function void report_phase(uvm_phase phase);


endclass 

//-----------------  constructor new method  -------------------//
 
function ram_rd_monitor::new (string name = "ram_rd_monitor", uvm_component parent);
	super.new(name, parent);
	// create object for handle monitor_port using new
    monitor_port = new("monitor_port", this);
endfunction : new

//-----------------  build() phase method  -------------------//
 
 function void ram_rd_monitor::build_phase(uvm_phase phase);
	// call super.build_phase(phase);
    super.build_phase(phase);
	// get the config object using uvm_config_db 
	if(!uvm_config_db #(ram_rd_agent_config)::get(this,"","ram_rd_agent_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
endfunction

//-----------------  connect() phase method  -------------------//
// in connect phase assign the configuration object's virtual interface
// to the monitor's virtual interface instance(handle --> "vif")
function void ram_rd_monitor::connect_phase(uvm_phase phase);
    vif = m_cfg.vif;
endfunction


//-----------------  run() phase method  -------------------//
	

// In forever loop
// Call task collect_data
task ram_rd_monitor::run_phase(uvm_phase phase);
    forever
		// Call collect data task
		collect_data();     
endtask


//Collect Reference Data from DUV IF 
task ram_rd_monitor::collect_data();

    read_xtn data_sent;
	// Create an instance data_sent
    data_sent= read_xtn::type_id::create("data_sent");

    @(posedge vif.rmon_cb.read);
    data_sent.read = vif.rmon_cb.read;
    data_sent.address = vif.rmon_cb.rd_address;
    data_sent.xtn_type = (data_sent.address == 'd1904) ? BAD_XTN : GOOD_XTN ;
    repeat(2)
    @(vif.rmon_cb);
    data_sent.data = vif.rmon_cb.data_out;
    //Debug Print - Set Verbosity level UVM_HIGH only to debug
    `uvm_info("RAM_RD_MONITOR",$sformatf("printing from monitor \n %s", data_sent.sprint()),UVM_LOW) 
    //Sending Read transaction to SB for lab09
    monitor_port.write(data_sent);
  
endtask 

// UVM report_phase
function void ram_rd_monitor::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: RAM Read Monitor Collected %0d Transactions", m_cfg.mon_rcvd_xtn_cnt), UVM_LOW)
endfunction         
     
    


