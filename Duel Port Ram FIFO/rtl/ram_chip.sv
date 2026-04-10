Filename		: 	ram_chip.sv

Description 	: 	RTL file for RAM
************************************************************************/

//RAM - Chip
module ram_chip (ram_if.DUV_MP mif);

  ram_4096 RTL  (.clk(mif.clk),
                 .data_in(mif.data_in),
                 .rd_address(mif.rd_address),
                 .wr_address(mif.wr_address),
                 .read(mif.read),
                 .write(mif.write),
                 .data_out(mif.data_out)) ;
endmodule
