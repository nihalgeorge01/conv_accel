//if both cpu and accel try to access this then fucked, some inrrupt handler?
module VRAM(input clk,
            input [23:0] destination_addr_from_acc,
            input [23:0] destination_addr_from_cpu,
            input [7:0] dwdata_from_acc,
            input [7:0] dwdata_from_cpu,
            input [23:0] daddr,
            input [23:0] daddr_from_cpu,
            
            input dwe_from_acc,
            input dwe_from_cpu,
            output [199:0] drdata,
            output [31:0] drdata_to_cpu,
            input [15:0] image_size
            );

    reg [7:0] vmem[0:2**24 - 1]; //needs 16bits to be byte addressable 

    //reg [39:0] vmem[0:13108]; //will read 5 values at a time
    //needs 17 bits to be byte addressable, further complications integrating with cpu, writing data as well sligtly complicated i guess 

    //overall 4*4 filter highly recommended, will save a lot of random ass work
    //doing 4*4 for now
    
    assign drdata[7:0] = vmem[daddr];
    assign drdata[15:8] = vmem[daddr+1];
    assign drdata[23:16] = vmem[daddr+2];
    assign drdata[31:24] = vmem[daddr+3];
    assign drdata[39:32] = vmem[daddr+4];

    assign drdata[47:40] = vmem[daddr+image_size];
    assign drdata[55:48] = vmem[daddr+image_size+1];
    assign drdata[63:56] = vmem[daddr+image_size+2];
    assign drdata[71:64] = vmem[daddr+image_size+3];
    assign drdata[79:72] = vmem[daddr+image_size+4];

    assign drdata[87:80] = vmem[daddr+2*image_size];
    assign drdata[95:88] = vmem[daddr+2*image_size+1];
    assign drdata[103:96] = vmem[daddr+2*image_size+2];
    assign drdata[111:104] = vmem[daddr+2*image_size+3];
    assign drdata[119:112] = vmem[daddr+2*image_size+4];

    assign drdata[127:120] = vmem[daddr+3*image_size];
    assign drdata[135:128] = vmem[daddr+3*image_size+1];
    assign drdata[143:136] = vmem[daddr+3*image_size+2];
    assign drdata[151:144] = vmem[daddr+3*image_size+3];
    assign drdata[159:152] = vmem[daddr+3*image_size+4];

    assign drdata[167:160] = vmem[daddr+4*image_size];
    assign drdata[175:168] = vmem[daddr+4*image_size+1];
    assign drdata[183:176] = vmem[daddr+4*image_size+2];
    assign drdata[191:184] = vmem[daddr+4*image_size+3];
    assign drdata[199:192] = vmem[daddr+4*image_size+4];

    assign drdata_to_cpu[7:0] = vmem[daddr_from_cpu];
    assign drdata_to_cpu[15:8] = vmem[daddr_from_cpu+1];
    assign drdata_to_cpu[23:16] = vmem[daddr_from_cpu+2];
    assign drdata_to_cpu[31:24] = vmem[daddr_from_cpu+3];
    

    initial begin
            $readmemh("firmware/img_gray_bytes.hex", vmem); //PUT LOCATION HERE
    end 


    always @(posedge clk) begin 
            
            if(dwe_from_acc) begin 
                    vmem[destination_addr_from_acc] = dwdata_from_acc;
            end 
            else if (dwe_from_cpu) begin 
                    vmem[destination_addr_from_cpu] = dwdata_from_cpu;
            end 
    
            //writing 8 bits at a time for now 
    // TODO: incorrect
            //if(dwe_from_cpu ^ dwe_from_acc) vmem[destination_addr_from_cpu] = dwdata_from_cpu;
    end 

endmodule 





    







    



