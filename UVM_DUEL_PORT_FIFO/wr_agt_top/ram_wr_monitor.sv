

// Extend ram_wr_monitor from uvm_monitor

class ram_wr_monitor extends uvm_monitor;

	// Factory Registration
	`uvm_component_utils(ram_wr_monitor)

	// Declare virtual interface handle with WMON_MP as modport
   	virtual ram_if.WMON_MP vif;

	// Declare the ram_wr_agent_config handle as "m_cfg"
    ram_wr_agent_config m_cfg;
	
	//Declare Analysis TLM port to connect the monitor to the scoreboard
	uvm_analysis_port#(write_xtn)monitor_port;
	

	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
	extern function new(string name = "ram_wr_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern function void report_phase(uvm_phase phase);
endclass 
//-----------------  constructor new method  -------------------//
function ram_wr_monitor::new(string name = "ram_wr_monitor", uvm_component parent);
	super.new(name,parent);
	//create instance of analysis port	
	monitor_port =  new("monitor_port",this);
endfunction

//-----------------  build() phase method  -------------------//
function void ram_wr_monitor::build_phase(uvm_phase phase);
	// call super.build_phase(phase);
    super.build_phase(phase);
	// get the config object using uvm_config_db  
	if(!uvm_config_db #(ram_wr_agent_config)::get(this,"","ram_wr_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
endfunction

//-----------------  connect() phase method  -------------------//
// in connect phase assign the configuration object's virtual interface
// to the monitor's virtual interface instance(handle --> "vif")
function void ram_wr_monitor::connect_phase(uvm_phase phase);
    vif = m_cfg.vif;
endfunction


//-----------------  run() phase method  -------------------//
	

// In forever loop
// Call task collect_data
task ram_wr_monitor::run_phase(uvm_phase phase);
    forever
       // Call collect data task
       collect_data();     
endtask


// Collect Reference Data from DUV IF 
task ram_wr_monitor::collect_data();
    write_xtn data_sent;
	// Create an instance data_sent
	data_sent= write_xtn::type_id::create("data_sent");
	@(posedge vif.wmon_cb.write);
    data_sent.write = vif.wmon_cb.write;
    data_sent.data = vif.wmon_cb.data_in;
    data_sent.address = vif.wmon_cb.wr_address;
    data_sent.xtn_type = (data_sent.address == 'd1904) ? BAD_XTN : GOOD_XTN ;
	
    `uvm_info("RAM_WR_MONITOR",$sformatf("printing from monitor \n %s", data_sent.sprint()),UVM_LOW) 
	//Debug Print - Set Verbosity level UVM_HIGH only to debug
    `uvm_info("RAM_WR_MONITOR",$sformatf("printing from monitor \n %s", data_sent.sprint()),UVM_LOW) 
	// LAB : Call write method of analysis port after collecting the data
	 monitor_port.write(data_sent);
  	//increment mon_rcvd_xtn_cnt
    m_cfg.mon_rcvd_xtn_cnt++;
  endtask 
      	  

// UVM report_phase
function void ram_wr_monitor::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: RAM Write Monitor Collected %0d Transactions", m_cfg.mon_rcvd_xtn_cnt), UVM_LOW)
endfunction : report_phase

