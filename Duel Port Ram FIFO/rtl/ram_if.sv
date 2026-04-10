Filename		:   ram_if.sv

Description		:	Interface file for RAM
************************************************************************/


`define RAM_WIDTH 64
`define ADDR_SIZE 12

interface ram_if(input bit clock);
  
	logic [`RAM_WIDTH-1 : 0] data_in;       // Data Input
	logic [`ADDR_SIZE-1 : 0] rd_address;    // Read Address
	logic [`ADDR_SIZE-1 : 0] wr_address;    // Write Address
	logic read;                             // Read Control
	logic write;                            // Write Control
	bit clk;

	wire [`RAM_WIDTH-1 : 0] data_out;

	assign clk = clock;

	//DUV Modport
	modport DUV_MP (input data_in, rd_address, wr_address, read, write, clk,
					output data_out);

	//TB Modports and CBs
	//Write OVC Driver CB
	clocking wdr_cb @ (posedge clock);
		default input #1 output #1;
		output data_in;
		output wr_address;
		output write;
	endclocking

	//Read OVC Driver CB
	clocking rdr_cb @ (posedge clock);
		default input #1 output #1;
		output rd_address;
		output read;
		input data_out;
	endclocking

	//Write OVC Monitor CB
    //Reads the DUV inputs @ negedge clock 
	clocking wmon_cb @(negedge clock);
		default input #1 output #1;
		input data_in;
		input wr_address;
		input write;
	endclocking

	//Read OVC Monitor CB
	clocking rmon_cb @(negedge clock);
		default input #1 output #1;
		input data_out;
		input rd_address;
		input read;
	endclocking

	//Write OVC Driver MP
	modport WDR_MP (clocking wdr_cb);
	//Read OVC Driver MP
	modport RDR_MP (clocking rdr_cb);
	//Write OVC Monitor MP
	modport WMON_MP (clocking wmon_cb);
	//Read OVC Monitor MP
	modport RMON_MP (clocking rmon_cb);

  //Read monitor debug logic
  // assign data_out = (read) ? {$random,$random} : '0; 

endinterface
