//------------------------------------------
// CLASS DESCRIPTION
//------------------------------------------

// Extend ram_tb from uvm_env
class ram_tb extends uvm_env;

       
    // Factory Registration
  	`uvm_component_utils(ram_tb)

	
	//Declare dynamic array of handles for ram_wr_agt_top, ram_rd_agt_top  as wagt_top,ragt_top and respectively
	ram_wr_agt_top wagt_top[];
	ram_rd_agt_top ragt_top[];
	// Declare handle for ram_virtual_sequencer as  v_sequencer
	ram_virtual_sequencer v_sequencer;
	//  Declare dynamic array of handles for ram scoreboard as sb
	ram_scoreboard sb[];
	// Declare handle for env configuration object as m_cfg
    ram_env_config m_cfg;
	//------------------------------------------
	// Methods
	//------------------------------------------

	// Standard UVM Methods:
	extern function new(string name = "ram_tb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass: ram_tb
	
//-----------------  constructor new method  -------------------//
// Define Constructor new() function
function ram_tb::new(string name = "ram_tb", uvm_component parent);
	super.new(name,parent);
endfunction

//-----------------  build phase method  -------------------//

function void ram_tb::build_phase(uvm_phase phase);
	// get the config object using uvm_config_db 
	if(!uvm_config_db #(ram_env_config)::get(this,"","ram_env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
    if(m_cfg.has_wagent)
		begin
			// initialize the dynamic array wagt_top[] to m_cfg.no_of_duts
			wagt_top = new[m_cfg.no_of_duts];
			// inside a foreach loop of wagt_top[i]
			foreach(wagt_top[i])
				begin
					// set ram_wr_agent_config into the database using the
					// ram_env_config's ram_wr_agent_config object 
					uvm_config_db #(ram_wr_agent_config)::set(this,$sformatf("wagt_top[%0d]*",i),  "ram_wr_agent_config", m_cfg.m_wr_agent_cfg[i]);
					// Create the instances of wagt_top[i] handles
					wagt_top[i]=ram_wr_agt_top::type_id::create($sformatf("wagt_top[%0d]",i) ,this);
                end 
        end	
		
    if(m_cfg.has_ragent == 1) 
		begin
			// initialize the dynamic array ragt_top[] to m_cfg.no_of_duts
            ragt_top = new[m_cfg.no_of_duts];
			// inside a foreach loop of ragt_top[i]
            foreach(ragt_top[i]) 
				begin
					// set ram_rd_agent_config into the database using the
					// ram_env_config's ram_rd_agent_config object 
					uvm_config_db #(ram_rd_agent_config)::set(this,$sformatf("ragt_top[%0d]*",i),  "ram_rd_agent_config", m_cfg.m_rd_agent_cfg[i]);
					// Create the instances of wagt_top[i]
					ragt_top[i]=ram_rd_agt_top::type_id::create($sformatf("ragt_top[%0d]", i),this);
				end
        end

    super.build_phase(phase);
    if(m_cfg.has_virtual_sequencer)
		// Create the instance of v_sequencer handle 
	    v_sequencer=ram_virtual_sequencer::type_id::create("v_sequencer",this);
		
    if(m_cfg.has_scoreboard)
		begin
			// initialize the dynamic array sb[] to m_cfg.no_of_duts
            sb = new[m_cfg.no_of_duts];
			// Create the instances of ram_scoreboard  
            foreach (sb[i]) 
                sb[i] = ram_scoreboard::type_id::create($sformatf("sb[%0d]",i),this);
        end
endfunction

//-----------------  connect phase method  -------------------//

// In connect phase
// Connect virtual sequencer's sub sequencers to the envirnoment's
// write & read sequencers
//  Inside a foreach loops for *agt_top[i]
// Hint : v_sequencer.wr_seqr[i] = wagt_top[i].agnth.seqrh
// 	  v_sequencer.rd_seqr[i] = ragt_top[i].agnth.seqrh
 
function void ram_tb::connect_phase(uvm_phase phase);
    if(m_cfg.has_virtual_sequencer)
		begin
            if(m_cfg.has_wagent)
				foreach(wagt_top[i]) 
					begin 
							v_sequencer.wr_seqrh[i] = wagt_top[i].agnth.seqrh;                    
					end
                        
			if(m_cfg.has_ragent) 
				begin
					foreach(ragt_top[i]) 
						v_sequencer.rd_seqrh[i] = ragt_top[i].agnth.seqrh;
                end
        end
// connect the corressponding analysis port of all the
// monitors to the analysis export of all the tlm analysis
// fifo's in the scoreboard 
// Inside a foreach loops for *agt_top[i]
// Hint : wagt_top[i].agnth.monh.monitor_port.connect(sb[i].fifo_wrh.analysis_export)
//        ragt_top[i].agnth.monh.monitor_port.connect(sb[i].fifo_rdh.analysis_export)

	if(m_cfg.has_scoreboard)
		begin
    		foreach(wagt_top[i])
     				wagt_top[i].agnth.monh.monitor_port.connect(sb[i].fifo_wrh.analysis_export);
   			foreach(ragt_top[i])
      				ragt_top[i].agnth.monh.monitor_port.connect(sb[i].fifo_rdh.analysis_export);
		end
endfunction

