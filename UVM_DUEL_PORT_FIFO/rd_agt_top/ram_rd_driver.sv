// Extend ram_rd_driver from uvm driver parameterized by read_xtn
class ram_rd_driver extends uvm_driver #(read_xtn);

	// Factory Registration

	`uvm_component_utils(ram_rd_driver)

	// Declare virtual interface handle with RDR_MP as modport
	virtual ram_if.RDR_MP vif;

	// Declare the ram_rd_agent_config handle as "m_cfg"
    ram_rd_agent_config m_cfg;

	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
     	
	extern function new(string name ="ram_rd_driver",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(read_xtn duv_xtn);
	extern function void report_phase(uvm_phase phase);
endclass

//-----------------  constructor new method  -------------------//
 
 function ram_rd_driver::new (string name ="ram_rd_driver", uvm_component parent);
	super.new(name, parent);
endfunction : new

//-----------------  build() phase method  -------------------//
function void ram_rd_driver::build_phase(uvm_phase phase);
	// call super.build_phase(phase);
    super.build_phase(phase);
	// get the config object using uvm_config_db 
	if(!uvm_config_db #(ram_rd_agent_config)::get(this,"","ram_rd_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
endfunction

//-----------------  connect() phase method  -------------------//
// in connect phase assign the configuration object's virtual interface
// to the driver's virtual interface instance(handle --> "vif")
function void ram_rd_driver::connect_phase(uvm_phase phase);
    vif = m_cfg.vif;
endfunction

//-----------------  run() phase method  -------------------//
// In forever loop
// Get the sequence item using seq_item_port
// Call send_to_dut task 
// Get the next sequence item using seq_item_port  

task ram_rd_driver::run_phase(uvm_phase phase);
    forever
	begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end
endtask


//-----------------  task send_to_dut() method  -------------------//

 task ram_rd_driver::send_to_dut (read_xtn duv_xtn);

   	// Print the transaction
    `uvm_info("RAM_RD_DRIVER",$sformatf("printing from driver \n %s", duv_xtn.sprint()),UVM_LOW) 
	repeat(5)
      	@(vif.rdr_cb);
    //Driving XTN
   	vif.rdr_cb.rd_address <= duv_xtn.address;
   	vif.rdr_cb.read <= duv_xtn.read;
  
   	repeat(2) 
		@(vif.rdr_cb);
  	duv_xtn.data  = vif.rdr_cb.data_out;
    //Removing data
   	vif.rdr_cb.rd_address <= '0;
   	vif.rdr_cb.read <= '0; 

    repeat(5)
		@(vif.rdr_cb);
	// increment drv_data_sent_cnt
   	m_cfg.drv_data_sent_cnt++;

 endtask 

 // UVM report_phase
 function void ram_rd_driver::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: RAM read driver sent %0d transactions", m_cfg.drv_data_sent_cnt), UVM_LOW)
 endfunction 