

// Extend ram_wr_driver from uvm driver parameterized by write_xtn
class ram_wr_driver extends uvm_driver #(write_xtn);

	// Factory Registration

	`uvm_component_utils(ram_wr_driver)

	// Declare virtual interface handle with WDR_MP as modport
	virtual ram_if.WDR_MP vif;

	// Declare the ram_wr_agent_config handle as "m_cfg"
    ram_wr_agent_config m_cfg;



	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
     	
	extern function new(string name ="ram_wr_driver",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(write_xtn xtn);
	extern function void report_phase(uvm_phase phase);

endclass

//-----------------  constructor new method  -------------------//
 // Define Constructor new() function
function ram_wr_driver::new(string name ="ram_wr_driver",uvm_component parent);
	super.new(name,parent);
endfunction

//-----------------  build() phase method  -------------------//
function void ram_wr_driver::build_phase(uvm_phase phase);
	// call super.build_phase(phase);
	super.build_phase(phase);
	// get the config object using uvm_config_db 
	if(!uvm_config_db #(ram_wr_agent_config)::get(this,"","ram_wr_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
endfunction

//-----------------  connect() phase method  -------------------//
// in connect phase assign the configuration object's virtual interface
// to the driver's virtual interface instance(handle --> "vif")
function void ram_wr_driver::connect_phase(uvm_phase phase);
    vif = m_cfg.vif;
endfunction


//-----------------  run() phase method  -------------------//
// In forever loop
// Get the sequence item using seq_item_port
// Call send_to_dut task 
// Get the next sequence item using seq_item_port  

task ram_wr_driver::run_phase(uvm_phase phase);
    forever 
		begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			seq_item_port.item_done();
		end
endtask

//-----------------  task send_to_dut() method  -------------------//

// Add task send_to_dut(write_xtn handle as an input argument)
	
task ram_wr_driver::send_to_dut(write_xtn xtn);
	// Print the transaction
    `uvm_info("RAM_WR_DRIVER",$sformatf("printing from driver \n %s", xtn.sprint()),UVM_LOW) 
    // Add the write logic
      
    repeat(2)
    @(vif.wdr_cb);
   
	// Driving XTN
	vif.wdr_cb.wr_address <= xtn.address;
	vif.wdr_cb.write <= xtn.write;
    vif.wdr_cb.data_in <= xtn.data;
   
    @(vif.wdr_cb);

    // Removing data
    vif.wdr_cb.wr_address <= '0;
    vif.wdr_cb.write <= '0;
    vif.wdr_cb.data_in <= '0;

    repeat(5)
    @(vif.wdr_cb);
	
// increment drv_data_sent_cnt
   	 m_cfg.drv_data_sent_cnt++;

 endtask 

  // UVM report_phase
  function void ram_wr_driver::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: RAM write driver sent %0d transactions", m_cfg.drv_data_sent_cnt), UVM_LOW)
  endfunction


