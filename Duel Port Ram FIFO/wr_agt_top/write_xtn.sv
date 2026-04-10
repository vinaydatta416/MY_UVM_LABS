


// Extend write_xtn from uvm_sequence_item
class write_xtn extends uvm_sequence_item;
  
	// UVM Factory Registration Macro
	`uvm_object_utils(write_xtn)

	//------------------------------------------
	// DATA MEMBERS (Outputs non-rand, inputs rand)
	//------------------------------------------

	 
		
	// Add the rand fields - data (`RAM_WIDTH-1:0), address(`ADDR_SIZE – 1:0),declared in tb_defs.sv
	// write (type bit) 

	rand bit[`RAM_WIDTH-1 : 0] data;    
	rand bit[`ADDR_SIZE-1 : 0] address;
	rand bit write;
  
	// Add the rand control knobs declared in tb_defs.sv

	// xtn_type (enumerated type addr_t)  -  for controlling the type of transaction 
	// xtn_delay (integer type) - for inserting delay between transactions
	
	rand addr_t xtn_type;
	rand bit[63:0] xtn_delay;
         
	//------------------------------------------
	// CONSTRAINTS
	//------------------------------------------
	 
	// Add the following constraints :
	// Data between 20 through 90
	// Address between 0 through 200
	// Distribute weights for xtn_type : BAD_XTN=2 and GOOD_XTN=30

	constraint a{ data inside {[20:90]};
		      address inside {[0:200]};
		      xtn_type dist {BAD_XTN:=2 , GOOD_XTN:=30}; 
		    }
	//------------------------------------------
	// METHODS
	//------------------------------------------

	// Standard UVM Methods like constructor,do_compare,do_copy,do_print,post_randomize
	extern function new(string name = "write_xtn");
	extern function void do_copy(uvm_object rhs);
	extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
	extern function void do_print(uvm_printer printer);
	extern function void post_randomize();

endclass:write_xtn

	//-----------------  constructor new method  -------------------//
	//Add code for new()

function write_xtn::new(string name = "write_xtn");
	super.new(name);
endfunction:new
	  
//-----------------  do_copy method  -------------------//
//Add code for do_copy() to copy address, data, write, xtn_type and xtn_delay
function void write_xtn::do_copy (uvm_object rhs);

    // handle for overriding the variable
    write_xtn rhs_;

	 // Add a check for rhs_ using $cast to check that the object types are 
	 // compatible
    if(!$cast(rhs_,rhs))
		begin
			`uvm_fatal("do_copy","cast of the rhs object failed")
		end
    super.do_copy(rhs);

	// Copy over data members:
	// <var_name> = rhs_.<var_name>;

    data= rhs_.data;
    address= rhs_.address;
    write= rhs_.write;
    xtn_type= rhs_.xtn_type;
    xtn_delay= rhs_.xtn_delay;

endfunction:do_copy


//-----------------  do_compare method -------------------//

//Add code for do_compare() to compare address, data, write, xtn_type and xtn_delay
function bit  write_xtn::do_compare (uvm_object rhs,uvm_comparer comparer);

	// handle for overriding the variable
    write_xtn rhs_;
	// Add a check for rhs_ using $cast to check that the object types are 
	// compatible
    if(!$cast(rhs_,rhs)) 
		begin
			`uvm_fatal("do_compare","cast of the rhs object failed")
			return 0;
		end

	  // Compare the data members:
	  // <var_name> == rhs_.<var_name>;

	return super.do_compare(rhs,comparer) &&
	data== rhs_.data &&
	address== rhs_.address &&
	write== rhs_.write &&
	xtn_type== rhs_.xtn_type &&
	xtn_delay== rhs_.xtn_delay;

endfunction:do_compare 

//-----------------  do_print method  -------------------//
//Use printer.print_field for integral variables
//Use printer.print_generic for enum variables
function void  write_xtn::do_print (uvm_printer printer);
	super.do_print(printer);

   
    //              	srting name   		bitstream value     size    radix for printing
    printer.print_field( "data", 			this.data, 	    	64,		 UVM_DEC		);
    printer.print_field( "address", 		this.address, 	    12,		 UVM_DEC		);
    printer.print_field( "write", 			this.write, 	    '1,		 UVM_DEC		);
    printer.print_field( "xtn_delay", 		this.xtn_delay,     65,		 UVM_DEC		);
   
    //  	         	   variable name	xtn_type		$bits(variable name) 	variable name.name
    printer.print_generic( "xtn_type", 		"addr_t",		$bits(xtn_type),		xtn_type.name);

endfunction:do_print
    

function void write_xtn::post_randomize();
    if(xtn_type == BAD_XTN)
		begin
			this.address = 6000;
		end
endfunction : post_randomize
   
 
   

