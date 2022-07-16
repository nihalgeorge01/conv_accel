module adder(
    input[399:0] prods, 
    input clk, 
    output[20:0] out
);

    wire signed [15:0] p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25;
    assign p1  = prods[ 15:  0];
    assign p2  = prods[ 31: 16];
    assign p3  = prods[ 47: 32];
    assign p4  = prods[ 63: 48];
    assign p5  = prods[ 79: 64];
    assign p6  = prods[ 95: 80];
    assign p7  = prods[111: 96];
    assign p8  = prods[127:112];
    assign p9  = prods[143:128];
    assign p10 = prods[159:144];
    assign p11 = prods[175:160];
    assign p12 = prods[191:176];
    assign p13 = prods[207:192];
    assign p14 = prods[223:208];
    assign p15 = prods[239:224];
    assign p16 = prods[255:240];
    assign p17 = prods[271:256];
    assign p18 = prods[287:272];
    assign p19 = prods[303:288];
    assign p20 = prods[319:304];
    assign p21 = prods[335:320];
    assign p22 = prods[351:336];
    assign p23 = prods[367:352];
    assign p24 = prods[383:368];
    assign p25 = prods[399:384];


	wire signed  [20:0] sum11, sum12, sum13, sum14, sum15, sum16, sum17, sum18, sum19, sum1a, sum1b, sum1c,sum1d, sum21, sum22, sum23, sum24, sum25, sum26, sum27, sum31, sum32, sum33, sum34, sum41, sum42, sum5;
	reg	signed [20:0] sumreg11, sumreg12, sumreg13, sumreg14, sumreg15, sumreg16, sumreg17, sumreg18, sumreg19, sumreg1a, sumreg1b, sumreg1c, sumreg1d,
        sumreg21, sumreg22, sumreg23, sumreg24, sumreg25, sumreg26,sumreg27,
        sumreg31, sumreg32, sumreg33, sumreg34,
        sumreg41, sumreg42,
        sumreg5;

	// Registers
	always @ (posedge clk)
		begin
			sumreg11 <= sum11;
			sumreg12 <= sum12;
			sumreg13 <= sum13;
			sumreg14 <= sum14;
            sumreg15 <= sum15;
            sumreg16 <= sum16;
            sumreg17 <= sum17;
            sumreg18 <= sum18;
            sumreg19 <= sum19;
            sumreg1a <= sum1a;
            sumreg1b <= sum1b;
            sumreg1c <= sum1c;
            sumreg1d <= sum1d;

            sumreg21 <= sum21;
            sumreg22 <= sum22;
            sumreg23 <= sum23;
            sumreg24 <= sum24;
            sumreg25 <= sum25;
            sumreg26 <= sum26;
            sumreg27 <= sum27;

            sumreg31 <= sum31;
            sumreg32 <= sum32;
            sumreg33 <= sum33;
            sumreg34 <= sum34;
            
            sumreg41 <= sum41;
            sumreg42 <= sum42;

            sumreg5 <= sum5;
		end

	// 16-bit additions
	assign sum11 = p1  + p2 ;
	assign sum12 = p3  + p4 ;
	assign sum13 = p5  + p6 ;
    assign sum14 = p7  + p8 ;
    assign sum15 = p9  + p10;
    assign sum16 = p11 + p12;
    assign sum17 = p13 + p14;
    assign sum18 = p15 + p16;
    assign sum19 = p17 + p18;
    assign sum1a = p19 + p20;
    assign sum1b = p21 + p22;
    assign sum1c = p23 + p24;
    assign sum1d = p25;
    
    assign sum21 = sumreg11 + sumreg12;
    assign sum22 = sumreg13 + sumreg14;
    assign sum23 = sumreg15 + sumreg16;
    assign sum24 = sumreg17 + sumreg18;
    assign sum25 = sumreg19 + sumreg1a;
    assign sum26 = sumreg1b + sumreg1c;
    assign sum27 = sumreg1d;

    assign sum31 = sumreg21 + sumreg22;
    assign sum32 = sumreg23 + sumreg24;
    assign sum33 = sumreg25 + sumreg26;
    assign sum34 = sumreg27;

    assign sum41 = sumreg31 + sumreg32;
    assign sum42 = sumreg33 + sumreg34;

	assign sum5 = sumreg41 + sumreg42;
	assign out = sumreg5;

endmodule