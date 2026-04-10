Filename		:   ram_soc.sv

Description		: 	RTL code for RAM SOC
************************************************************************/
//RAM - SoC
module ram_soc (ram_if.DUV_MP mif0,
                ram_if.DUV_MP mif1,
                ram_if.DUV_MP mif2,
                ram_if.DUV_MP mif3);

	ram_chip MB1 (.mif(mif0));
	ram_chip MB2 (.mif(mif1));
	ram_chip MB3 (.mif(mif2));
	ram_chip MB4 (.mif(mif3));

endmodule
