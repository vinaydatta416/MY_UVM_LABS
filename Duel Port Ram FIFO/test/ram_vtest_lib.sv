// Extend ram_base_test from uvm_test;
class ram_base_test extends uvm_test;

   // Factory Registration
	`uvm_component_utils(ram_base_test)

    // Declare the handles for env, env config_object, wr_agent config_object and
    // rd_agent config_object as ram_envh, m_tb_cfg, m_wr_cfg[] & m_rd_cfg[]
    // (dynamic array of handles)
    // respectively     	
    ram_tb ram_envh;
    ram_env_config m_tb_cfg;
    ram_wr_agent_config m_wr_cfg[];
    ram_rd_agent_config m_rd_cfg[];

	// Declare no_of_duts, has_ragent, has_wagent as int which are local
	// variables to this test class

    int no_of_duts = 4;
    int has_ragent = 1;
    int has_wagent = 1;
	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
	extern function new(string name = "ram_base_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void config_ram();
endclass


//-----------------  constructor new method  -------------------//
 // Define Constructor new() function
function ram_base_test::new(string name = "ram_base_test" , uvm_component parent);
	super.new(name,parent);
endfunction
//----------------- function config_ram()  -------------------//

function void ram_base_test::config_ram();
	if (has_wagent) 
		begin
			// initialize the dynamic array of handles for ram_wr_agent_config equal to no_of_duts
			m_wr_cfg = new[no_of_duts];
	
	        foreach(m_wr_cfg[i]) 
				begin
					// create the instance for ram_wr_agent_config
					m_wr_cfg[i]=ram_wr_agent_config::type_id::create($sformatf("m_wr_cfg[%0d]", i));
					// for all the configuration objects, set the following parameters 
					// is_active to UVM_ACTIVE
					// Get the virtual interface from the config database
					if(!uvm_config_db #(virtual ram_if)::get(this,"", $sformatf("vif_%0d",i),m_wr_cfg[i].vif))
					
					`uvm_fatal("VIF CONFIG","cannot get()interface vif from uvm_config_db. Have you set() it?") 
					m_wr_cfg[i].is_active = UVM_ACTIVE;
					
					// assign the ram_wr_agent_config handle to the enviornment
					// config's(ram_env_config) ram_rd_agent_config handle
					m_tb_cfg.m_wr_agent_cfg[i] = m_wr_cfg[i];
                end
        end
		 
//------------------------------------------------------------------
		
		// read config object
    if (has_ragent) 
		begin
		
            // initialize the dynamic array of handles m_rd_cfg to no_of_duts
            m_rd_cfg = new[no_of_duts];

			foreach(m_rd_cfg[i])
				begin
					// create the instance for ram_rd_agent_config
					m_rd_cfg[i]=ram_rd_agent_config::type_id::create($sformatf("m_rd_cfg[%0d]", i));
					// for all the configuration objects, set the following parameters 
					// is_active to UVM_ACTIVE
					// Get the virtual interface from the config database

					if(!uvm_config_db #(virtual ram_if)::get(this,"", $sformatf("vif_%0d",i),m_rd_cfg[i].vif))
					`uvm_fatal("VIF CONFIG","cannot get()interface vif from uvm_config_db. Have you set() it?")
					m_rd_cfg[i].is_active = UVM_ACTIVE;
					// assign the ram_rd_agent_config handle to the enviornment
					// config's(ram_env_config) ram_rd_agent_config handle
					m_tb_cfg.m_rd_agent_cfg[i] = m_rd_cfg[i];
                
                end
        end
	// assign no_of_duts to local m_tb_cfg.no_of_duts
	// assign has_ragent to local m_tb_cfg.has_ragent
	// assign has_wagent to local m_tb_cfg.has_wagent
    m_tb_cfg.no_of_duts = no_of_duts;
    m_tb_cfg.has_ragent = has_ragent;
    m_tb_cfg.has_wagent = has_wagent;
		// assign 1 to m_tb_cfg.has_scoreboard
		m_tb_cfg.has_scoreboard= 1;
		
endfunction : config_ram


//-----------------  build() phase method  -------------------//

function void ram_base_test::build_phase(uvm_phase phase);
    // create the config object using uvm_config_db 
	m_tb_cfg=ram_env_config::type_id::create("m_tb_cfg");
    if(has_wagent)
		// initialize the dynamic array of handles m_tb_cfg.m_wr_agent_cfg & m_tb_cfg.m_rd_agent_cfg to no_of_duts
        m_tb_cfg.m_wr_agent_cfg = new[no_of_duts];
    if(has_ragent)
		// initialize the dynamic array of handles for ram_rd_agent_config equal to no_of_duts
        m_tb_cfg.m_rd_agent_cfg = new[no_of_duts];
    // Call function config_ram which configures all the parameters
    config_ram; 
	// set the config object into UVM config DB  
	uvm_config_db #(ram_env_config)::set(this,"*","ram_env_config",m_tb_cfg);
	// call super.build()
    super.build();
	// create the instance for ram_envh handle
	ram_envh=ram_tb::type_id::create("ram_envh", this);
endfunction

//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------

// Extend ram_single_addr_test from ram_base_test;
class ram_single_addr_test extends ram_base_test;

	// Factory Registration
	`uvm_component_utils(ram_single_addr_test)

	// Declare the handle for  ram_single_vseq virtual sequence
    ram_single_vseq ram_seqh;
	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
 	extern function new(string name = "ram_single_addr_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//-----------------  constructor new method  -------------------//

 // Define Constructor new() function
function ram_single_addr_test::new(string name = "ram_single_addr_test" , uvm_component parent);
	super.new(name,parent);
endfunction

//-----------------  build() phase method  -------------------//
            
function void ram_single_addr_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

//-----------------  run() phase method  -------------------//
task ram_single_addr_test::run_phase(uvm_phase phase);
	//raise objection
    phase.raise_objection(this);
	//create instance for sequence
    ram_seqh=ram_single_vseq::type_id::create("ram_seqh");
	//start the sequence wrt virtual sequencer
    ram_seqh.start(ram_envh.v_sequencer);
	//drop objection
    phase.drop_objection(this);
endtask   

//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------

// Extend ram_ten_addr_test from ram_base_test;
class ram_ten_addr_test extends ram_base_test;

  
	// Factory Registration
	`uvm_component_utils(ram_ten_addr_test)

	// Declare the handle for  ram_ten_vseq virtual sequence
    ram_ten_vseq ram_seqh;
	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
 	extern function new(string name = "ram_ten_addr_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//-----------------  constructor new method  -------------------//

// Define Constructor new() function
function ram_ten_addr_test::new(string name = "ram_ten_addr_test" , uvm_component parent);
	super.new(name,parent);
endfunction


//-----------------  build() phase method  -------------------//
            
function void ram_ten_addr_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction


//-----------------  run() phase method  -------------------//
task ram_ten_addr_test::run_phase(uvm_phase phase);
	//raise objection
    phase.raise_objection(this);
	//create instance for sequence
    ram_seqh=ram_ten_vseq::type_id::create("ram_seqh");
	//start the sequence wrt virtual sequencer
    ram_seqh.start(ram_envh.v_sequencer);
	//drop objection
    phase.drop_objection(this);
endtask   


//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------

// Extend ram_odd_addr_test from ram_base_test;
class ram_odd_addr_test extends ram_base_test;

  
	// Factory Registration
	`uvm_component_utils(ram_odd_addr_test)

	// Declare the handle for  ram_odd_vseq virtual sequence
    ram_odd_vseq ram_seqh;
	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
 	extern function new(string name = "ram_odd_addr_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//-----------------  constructor new method  -------------------//

// Define Constructor new() function
function ram_odd_addr_test::new(string name = "ram_odd_addr_test" , uvm_component parent);
	super.new(name,parent);
endfunction


//-----------------  build() phase method  -------------------//
            
function void ram_odd_addr_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction


//-----------------  run() phase method  -------------------//
task ram_odd_addr_test::run_phase(uvm_phase phase);
	//raise objection
    phase.raise_objection(this);
	//create instance for sequence
    ram_seqh=ram_odd_vseq::type_id::create("ram_seqh");
	//start the sequence wrt virtual sequencer
    ram_seqh.start(ram_envh.v_sequencer);
	//drop objection
    phase.drop_objection(this);
endtask   


//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------

// Extend ram_even_addr_test from ram_base_test;
class ram_even_addr_test extends ram_base_test;

  
	// Factory Registration
	`uvm_component_utils(ram_even_addr_test)

	// Declare the handle for  ram_even_vseq virtual sequence
    ram_even_vseq ram_seqh;
	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods:
 	extern function new(string name = "ram_even_addr_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//-----------------  constructor new method  -------------------//

 // Define Constructor new() function
function ram_even_addr_test::new(string name = "ram_even_addr_test" , uvm_component parent);
	super.new(name,parent);
endfunction


//-----------------  build() phase method  -------------------//
            
function void ram_even_addr_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

//-----------------  run() phase method  -------------------//
task ram_even_addr_test::run_phase(uvm_phase phase);
	//raise objection
    phase.raise_objection(this);
	//create instance for sequence
    ram_seqh=ram_even_vseq::type_id::create("ram_seqh");
	//start the sequence wrt virtual sequencer
    ram_seqh.start(ram_envh.v_sequencer);
	//drop objection
    phase.drop_objection(this);
endtask   


