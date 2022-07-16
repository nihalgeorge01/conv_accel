module axi4_mem_periph #(
	parameter AXI_TEST = 0,
	parameter VERBOSE = 0
) (
	/* verilator lint_off MULTIDRIVEN */

	input             clk,
	input             mem_axi_awvalid,
	output reg        mem_axi_awready,
	input      [31:0] mem_axi_awaddr,
	input      [ 2:0] mem_axi_awprot,

	input             mem_axi_wvalid,
	output reg        mem_axi_wready,
	input      [31:0] mem_axi_wdata,
	input      [ 3:0] mem_axi_wstrb,

	output reg        mem_axi_bvalid,
	input             mem_axi_bready,

	input             mem_axi_arvalid,
	output reg        mem_axi_arready,
	input      [31:0] mem_axi_araddr,
	input      [ 2:0] mem_axi_arprot,

	output reg        mem_axi_rvalid,
	input             mem_axi_rready,
	output reg [31:0] mem_axi_rdata,

	output            tests_passed
	// output reg        tests_passed
);
	reg [31:0]   memory [0:2048*1024/4-1] /* verilator public */;
	// Memory to store the JPEG image (1M) and working memory (2M)
	reg [31:0]   jpgmem [0:1024*1024/4-1] /* verilator public */;
	reg [31:0]   wkmem  [0:2048*1024/4-1] /* verilator public */;

	reg verbose;
	initial verbose = $test$plusargs("verbose") || VERBOSE;

	assign tests_passed = 1;
	// Could not load this from the test bench for some reason?
	integer i;
	initial begin
		$readmemh("firmware/jpg.hex", jpgmem);
		for (i=0; i<1000000; i=i+1) begin
			// $display("%08x", jpgmem[i]);
			wkmem[i] = 0;
		end
	end

	integer out_file;
	initial begin
		out_file = $fopen("output.dump", "w");
	end

	initial begin
		mem_axi_awready = 0;
		mem_axi_wready = 0;
		mem_axi_bvalid = 0;
		mem_axi_arready = 0;
		mem_axi_rvalid = 0;
		// tests_passed = 0;
	end

	reg latched_raddr_en = 0;
	reg latched_waddr_en = 0;
	reg latched_wdata_en = 0;

	reg fast_raddr = 0;
	reg fast_waddr = 0;
	reg fast_wdata = 0;

	reg [31:0] latched_raddr;
	reg [31:0] latched_waddr;
	reg [31:0] latched_wdata;
	reg [ 3:0] latched_wstrb;
	reg        latched_rinsn;

	wire [199:0] 	vram_drdata;
	wire [31:0]		vram_drdata_to_cpu;
	wire [15:0] 	vram_daddr_from_cpu;
	wire [15:0] 	vram_daddr_from_acc;
	wire [7:0] 		vram_dwdata_from_cpu;
	wire [7:0] 		vram_dwdata_from_acc;
	wire [15:0] 	vram_image_size;
	wire [15:0] 	vram_destination_addr_from_cpu;
	wire [15:0] 	vram_destination_addr_from_acc;
	
	wire 			vram_dwe_from_cpu;
	wire 			vram_dwe_from_acc;
	wire 			conv_accel_enable;
	
	reg [23:0] 		vram_daddr_from_cpu_reg;
	reg [23:0] 		vram_daddr_from_acc_reg;
	reg [23:0] 		vram_destination_addr_from_cpu_reg;
	reg [23:0] 		vram_destination_addr_from_acc_reg;
	reg [15:0] 		vram_image_size_reg;
	reg [7:0] 		vram_dwdata_from_cpu_reg;
	reg [7:0] 		vram_dwdata_from_acc_reg;
	reg [199:0]		vram_drdata_reg;
	reg [31:0]		vram_drdata_to_cpu_reg;
	reg 			vram_dwe_from_cpu_reg;
	reg 			vram_dwe_from_acc_reg;
	reg 			conv_accel_enable_reg;

	
	assign vram_daddr_from_cpu = vram_daddr_from_cpu_reg;
	assign vram_daddr_from_acc = vram_daddr_from_acc_reg;
	assign vram_destination_addr_from_cpu = vram_destination_addr_from_cpu_reg;
	assign vram_destination_addr_from_acc = vram_destination_addr_from_acc_reg;
	assign vram_dwe_from_cpu = vram_dwe_from_cpu_reg;
	assign vram_dwe_from_acc = vram_dwe_from_acc_reg;
	assign vram_image_size = vram_image_size_reg;
	assign vram_dwdata_from_cpu = vram_dwdata_from_cpu_reg;
	assign vram_dwdata_from_acc = vram_dwdata_from_acc_reg;  
	assign vram_drdata = vram_drdata_reg;
	// TODO literally everything fml
	assign conv_accel_enable = conv_accel_enable_reg;
	assign vram_drdata_to_cpu = vram_drdata_to_cpu_reg;
	

	VRAM vram(			
		.clk(clk),
		.destination_addr_from_acc(vram_destination_addr_from_acc),
		.destination_addr_from_cpu(vram_destination_addr_from_cpu),
		.dwdata_from_cpu(vram_dwdata_from_cpu),//
		.dwdata_from_acc(vram_dwdata_from_acc), //
		.daddr_from_cpu(vram_daddr_from_cpu),
		.daddr(vram_daddr_from_acc),
		.dwe_from_cpu(vram_dwe_from_cpu),
		.dwe_from_acc(vram_dwe_from_acc),
		.drdata(vram_drdata),
		.drdata_to_cpu(vram_drdata_to_cpu),
		.image_size(vram_image_size)
		);

	conv_accel conv_accel_inst(			
		.clk(clk),
		.enable(conv_accel_enable),
		.drdata(vram_drdata),
		.dwdata(vram_dwdata_from_acc),
		.destination_addr(vram_destination_addr_from_acc),
		.daddr(vram_daddr_from_acc),
		.ready(conv_accel_ready),
		.image_size(vram_image_size),
		.dwe(vram_dwe_from_acc)
		);

	task handle_axi_arvalid; begin
		mem_axi_arready <= 1;
		latched_raddr = mem_axi_araddr;
		latched_rinsn = mem_axi_arprot[2];
		latched_raddr_en = 1;
		fast_raddr <= 1;
	end endtask

	task handle_axi_awvalid; begin
		mem_axi_awready <= 1;
		latched_waddr = mem_axi_awaddr;
		latched_waddr_en = 1;
		fast_waddr <= 1;
	end endtask

	task handle_axi_wvalid; begin
		mem_axi_wready <= 1;
		latched_wdata = mem_axi_wdata;
		latched_wstrb = mem_axi_wstrb;
		latched_wdata_en = 1;
		fast_wdata <= 1;
	end endtask

	task handle_axi_rvalid; begin
		vram_dwe_from_cpu_reg = 0;
		
		if (verbose)
			$display("RD: ADDR=%08x DATA=%08x%s", latched_raddr, memory[latched_raddr >> 2], latched_rinsn ? " INSN" : "");
		if (latched_raddr < 2048*1024) begin
			mem_axi_rdata <= memory[latched_raddr >> 2];
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0;
		end else
		if ((latched_raddr >= 32'h3000_0000) && (latched_raddr < 32'h3100_0000)) begin
			// JPEG input image memory
			$display("JPG %08x: %08x", latched_raddr, jpgmem[(latched_raddr-'h3000_0000) >> 2]);
			mem_axi_rdata <= jpgmem[(latched_raddr-'h3000_0000) >> 2];
		end else

		if ((latched_raddr >= 32'h4000_0000) && (latched_raddr < 32'h4200_0000)) begin
			// Working memory
			// $display("WK  %08x: %08x", latched_raddr, wkmem[(latched_raddr-'h4000_0000) >> 2]);
			mem_axi_rdata <= wkmem[(latched_raddr-'h4000_0000) >> 2];
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0; // Why?
		end else
		if ((latched_raddr >= 32'h5000_0000) && (latched_raddr < 32'h5100_0000)) begin
			// VRAM internal memory
			// $display("JPG %08x: %08x", latched_raddr, jpgmem[(latched_raddr-'h3000_0000) >> 2]);
			// mem_axi_rdata <= jpgmem[(latched_raddr-'h3000_0000) >> 2];
			vram_daddr_from_cpu_reg = latched_raddr[15:0];
			mem_axi_rdata <= vram_drdata_to_cpu_reg; //HERE
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0; // Why?
		end else
		if ((latched_raddr >= 32'h6000_0000) && (latched_raddr < 32'h6100_0000)) begin
			// conv_accel ready signal
			mem_axi_rdata <= {31'd0, conv_accel_ready};
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0; // Why?
		end else begin
			$display("OUT-OF-BOUNDS MEMORY READ FROM %08x", latched_raddr);
			$finish;
		end
	end endtask

	task handle_axi_bvalid; begin

		if (verbose)
			$display("WR: ADDR=%08x DATA=%08x STRB=%04b", latched_waddr, latched_wdata, latched_wstrb);
		if (latched_waddr < 2048*1024) begin
		//	vram_dwe_from_cpu_reg = 0;
		//$display("MADE IT HERE");
			if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
			if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
			if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
			if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
		end else
		if (latched_waddr == 32'h1000_0000) begin
			vram_dwe_from_cpu_reg = 0;
			if (verbose) begin
				if (32 <= latched_wdata && latched_wdata < 128)
					$display("OUT: '%c'", latched_wdata[7:0]);
				else
					$display("OUT: %3d", latched_wdata);
			end else begin
				$write("%c", latched_wdata[7:0]);
`ifndef VERILATOR
				$fflush();
`endif
			end
		end else
		if (latched_waddr == 32'h2000_0000) begin
			// fwrite to output.ppm
			vram_dwe_from_cpu_reg = 0;
			$fwrite(out_file, "%c", latched_wdata[ 7: 0]);
			$fflush(out_file);
		end else 
		if ((latched_waddr >= 32'h3000_0000) && (latched_waddr < 32'h3100_0000)) begin
			vram_dwe_from_cpu_reg = 0;
			$display("JPEG memory is read-only!");
		end else 
		if ((latched_waddr >= 32'h4000_0000) && (latched_waddr < 32'h4200_0000)) begin
			if (latched_wstrb[1]) wkmem[(latched_waddr-'h4000_0000) >> 2][7: 0] <= latched_wdata[7: 0];
			if (latched_wstrb[1]) wkmem[(latched_waddr-'h4000_0000) >> 2][15: 8] <= latched_wdata[15: 8];
			if (latched_wstrb[2]) wkmem[(latched_waddr-'h4000_0000) >> 2][23:16] <= latched_wdata[23:16];
			if (latched_wstrb[3]) wkmem[(latched_waddr-'h4000_0000) >> 2][31:24] <= latched_wdata[31:24];
		end else
		if ((latched_waddr >= 32'h5000_0000) && (latched_waddr < 32'h5200_0000)) begin
			// Inefficient transfer cos taking only 8 bits out of 32
			if (latched_wstrb[0]) begin
				vram_dwe_from_cpu_reg = 1;
				vram_destination_addr_from_cpu_reg = latched_waddr[15:0];
				vram_dwdata_from_cpu_reg = latched_wdata[7:0];
			end
			// if (latched_wstrb[1]) wkmem[(latched_waddr-'h4000_0000) >> 2][15: 8] <= latched_wdata[15: 8];
			// if (latched_wstrb[2]) wkmem[(latched_waddr-'h4000_0000) >> 2][23:16] <= latched_wdata[23:16];
			// if (latched_wstrb[3]) wkmem[(latched_waddr-'h4000_0000) >> 2][31:24] <= latched_wdata[31:24];
		end else 
		if ((latched_waddr >= 32'h6000_0000) && (latched_waddr < 32'h6100_0000)) begin
			// Inefficient transfer cos taking only 8 bits out of 32
		     if (latched_wstrb[0]) begin
				conv_accel_enable_reg = 1'b1;
			end
		end else begin
			vram_dwe_from_cpu_reg = 0;
			$display("OUT-OF-BOUNDS MEMORY WRITE TO %08x", latched_waddr);
			$finish;
		end
		mem_axi_bvalid <= 1;
		latched_waddr_en = 0;
		latched_wdata_en = 0;
	end endtask

	always @(negedge clk) begin
		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr)) handle_axi_arvalid;
		if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr)) handle_axi_awvalid;
		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata)) handle_axi_wvalid;
		if (!mem_axi_rvalid && latched_raddr_en) handle_axi_rvalid;
		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en) handle_axi_bvalid;
	end

	always @(posedge clk) begin
		mem_axi_arready <= 0;
		mem_axi_awready <= 0;
		mem_axi_wready <= 0;

		fast_raddr <= 0;
		fast_waddr <= 0;
		fast_wdata <= 0;

		if (mem_axi_rvalid && mem_axi_rready) begin
			mem_axi_rvalid <= 0;
		end

		if (mem_axi_bvalid && mem_axi_bready) begin
			mem_axi_bvalid <= 0;
		end

		if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
			latched_raddr = mem_axi_araddr;
			latched_rinsn = mem_axi_arprot[2];
			latched_raddr_en = 1;
		end

		if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
			latched_waddr = mem_axi_awaddr;
			latched_waddr_en = 1;
		end

		if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
			latched_wdata = mem_axi_wdata;
			latched_wstrb = mem_axi_wstrb;
			latched_wdata_en = 1;
		end

		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr)) handle_axi_arvalid;
		if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr)) handle_axi_awvalid;
		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata)) handle_axi_wvalid;

		if (!mem_axi_rvalid && latched_raddr_en) handle_axi_rvalid;
		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en) handle_axi_bvalid;
	end
endmodule
