module conv_accel(input clk,
                  input enable,
                  input [199:0] drdata,
                  output [7:0] dwdata,
                  output [23:0] destination_addr,
                  output [23:0] daddr,
                  output [15:0] image_size,
                  output dwe,
                  output ready); //not sure if more inputs are required
    reg [7:0] kernels [24:0];
    reg [23:0] read_addr; 
    reg [23:0] write_addr;
    reg dwe_reg;
    reg [15:0] end_counter;
    reg [15:0] counter;
    reg ready_reg; 
    reg [15:0] filter_size;

    wire [19:0] d_out_final;
  //  wire [15:0] image_size;
    assign image_size = 16'd200;
   // wire [23:0] daddr; 
  //  wire [199:0] drdata;
   // wire [23:0] destination_addr; 
  //  wire [7:0] dwdata;

    assign dwdata = d_out_final[7:0]; //LSB for now, we'll see 
    assign daddr = read_addr;
    assign destination_addr = write_addr;
    assign dwe = dwe_reg;
    


//     VRAM get_And_write(.clk(clk),
//                         .destination_addr(destination_addr),
//                         .dwdata(dwdata),
//                         .daddr(daddr),
//                         .dwe(dwe),
//                         .drdata(drdata),
//                         .image_size(image_size));


    initial begin
            $readmemh("firmware/ker_gray_bytes.hex", kernels); //PUT LOCATION HERE
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 0e5f741 (Add accelerator driver code)
            read_addr = 16'd0;
            write_addr = 16'ha000;
            dwe_reg = 1'b0;
            counter = 16'd0;
            end_counter = 4'd0;
            ready_reg = 1'b0;
<<<<<<< HEAD
            filter_size = 16'd5;
=======
            read_addr <= 16'd0;
            write_addr <= 16'ha000;
            dwe_reg< = 1'b0;
            add_one_five <= 1'b0;
            counter <= 16'd0;
            end_counter <= 4'd0;
            ready_reg <= 1'b0;
>>>>>>> 7814bb9 (Added readmemh for taking custom image)
=======
>>>>>>> 0e5f741 (Add accelerator driver code)
    end 

    wire [399:0] adder_inputs;
   // reg [399:0] adder_inputs_pipreg;
    //assign adder_inputs = adder_inputs_pipreg;
    

    always @(posedge(clk)) begin 
        
        
        if(enable  && !ready_reg) begin  //confirm 
<<<<<<< HEAD
            // $display("vram drdata: ", drdata);
            // $display("vram read_addr: ", read_addr);
            // if (daddr == 23'b0) begin
            //         $display("vram drdata: ", drdata);
            // end
            // if (read_addr == 0) begin
            //     $display("adder_inputs: ", adder_inputs);
            // end
=======
            $display("vram drdata: ", drdata);
            $display("vram read_addr: ", read_addr);
            // if (daddr == 23'b0) begin
            //         $display("vram drdata: ", drdata);
            // end

>>>>>>> 1b5abf6 (More debugs)
            if(counter < 16'd6 && end_counter == 0) begin 
                // $display("first if here counter: ", counter);
                // $display("first if here end_counter: ", end_counter);
                dwe_reg = 1'b0;
            end else dwe_reg = 1'b1;

<<<<<<< HEAD
            if(end_counter == image_size - filter_size + 1) begin 
                // $display("just before ready read_addr: ", read_addr);
                // $display("just before ready write_addr: ", read_addr);
                
=======
            if(end_counter == 16'd196) begin 
                $display("just before ready read_addr: ", read_addr);
                $display("just before ready write_addr: ", read_addr);
>>>>>>> 1b5abf6 (More debugs)
                ready_reg = 1'b1;

                read_addr = 16'd0;
                write_addr = 16'ha000;
                dwe_reg = 1'b0;
                counter = 16'd0;
                end_counter = 4'd0;
            end else
            if(counter == 16'd195) begin 
                // $display("second if here counter: ", counter);
                // $display("second if here end_counter: ", end_counter);
                counter = 0; 
                end_counter = end_counter + 1;
                read_addr = read_addr + filter_size; //FILTER SIZE
                write_addr = write_addr + 1; //confirm once
            end else begin 
                // $display("second else here counter: ", counter);
                // $display("second else here end_counter: ", end_counter);
                end_counter = end_counter;
                counter = counter + 1;
                read_addr = read_addr + 1; 
                write_addr = write_addr + 1;
            end 
            
            
        end 
    end 
    
    // always @(*) begin 
        
    // end

    assign ready = ready_reg;
    
    multiplier a1 (.out(adder_inputs[15:0]),.clk(clk),.a(drdata[7:0]), kernels[0]);
    multiplier a2 (.out(adder_inputs[31:16]),.clk(clk),.a(drdata[15:8]), kernels[1]);
    multiplier a3 (.out(adder_inputs[47:32]),.clk(clk),.a(drdata[23:16]), kernels[2]);
    multiplier a4 (.out(adder_inputs[63:48]),.clk(clk),.a(drdata[31:24]), kernels[3]);
    multiplier a5 (.out(adder_inputs[79:64]),.clk(clk),.a(drdata[39:32]), kernels[4]);
    multiplier a6 (.out(adder_inputs[95:80]),.clk(clk),.a(drdata[47:40]), kernels[5]);
    multiplier a7 (.out(adder_inputs[111:96]),.clk(clk),.a(drdata[55:48]), kernels[6]);
    multiplier a8 (.out(adder_inputs[127:112]),.clk(clk),.a(drdata[63:56]), kernels[7]);
    multiplier a9 (.out(adder_inputs[143:128]),.clk(clk),.a(drdata[71:64]), kernels[8]);
    multiplier a10 (.out(adder_inputs[159:144]),.clk(clk),.a(drdata[79:72]), kernels[9]);
    multiplier a11 (.out(adder_inputs[175:160]),.clk(clk),.a(drdata[87:80]), kernels[10]);
    multiplier a12 (.out(adder_inputs[191:176]),.clk(clk),.a(drdata[95:88]), kernels[11]);
    multiplier a13 (.out(adder_inputs[207:192]),.clk(clk),.a(drdata[103:96]), kernels[12]);
    multiplier a14 (.out(adder_inputs[223:208]),.clk(clk),.a(drdata[111:104]), kernels[13]);
    multiplier a15 (.out(adder_inputs[239:224]),.clk(clk),.a(drdata[119:112]), kernels[14]);
    multiplier a16 (.out(adder_inputs[255:240]),.clk(clk),.a(drdata[127:120]), kernels[15]);
    multiplier a17 (.out(adder_inputs[271:256]),.clk(clk),.a(drdata[135:128]), kernels[16]);
    multiplier a18 (.out(adder_inputs[287:272]),.clk(clk),.a(drdata[143:136]), kernels[17]);
    multiplier a19 (.out(adder_inputs[303:288]),.clk(clk),.a(drdata[151:144]), kernels[18]);
    multiplier a20 (.out(adder_inputs[319:304]),.clk(clk),.a(drdata[159:152]), kernels[19]);
    multiplier a21 (.out(adder_inputs[335:320]),.clk(clk),.a(drdata[167:160]), kernels[20]);
    multiplier a22 (.out(adder_inputs[351:336]),.clk(clk),.a(drdata[175:168]), kernels[21]);
    multiplier a23 (.out(adder_inputs[367:352]),.clk(clk),.a(drdata[183:176]), kernels[22]);
    multiplier a24 (.out(adder_inputs[383:368]),.clk(clk),.a(drdata[191:184]), kernels[23]);
    multiplier a25 (.out(adder_inputs[399:384]),.clk(clk),.a(drdata[199:192]), kernels[24]);

    adder add_final(.prods(adder_inputs),.clk(clk),.out(d_out_final));

endmodule 



            

        


