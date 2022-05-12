module risc_test();
    reg[2:0] temp_st;
    reg clk;
    integer k;
    parameter temp_eq = 3'b000, temp_small = 3'b001, temp_lg = 3'b010, temp_ext = 3'b011;
    wire clk1;
    
    risc_32_modify mips2(temp_st, clk, clk1);
    
    initial begin
        clk = 0;
        end
    always #2 clk = ~clk;
    
    initial
    begin
    for (k=0; k<31; k = k+1) mips2.regb[k] <= k;
    mips2.mem[0] <= 32'h8420000a; // r1 = r0 + 10
    mips2.mem[1] <= 32'h8440001e; // r2 = r0 + 30
    mips2.mem[2] <= 32'h1ff77800; // dummy
    mips2.mem[3] <= 32'h1ff77800; // dummy
    mips2.mem[4] <= 32'h00811000; // r4 = r1 + r2
    mips2.mem[5] <= 32'h84600014; // r3 = r0 + 20
    mips2.mem[6] <= 32'h1ff77800; // dummy
    mips2.mem[7] <= 32'h1ff77800; // dummy
    mips2.mem[8] <= 32'h04a30800; // r5 = r3 - r1
    mips2.mem[9] <= 32'h1ff77800; // dummy
    mips2.mem[10] <= 32'h1ff77800; // dummy
    mips2.mem[11] <= 32'h00e32800; // r7 = r3 + r5
    mips2.mem[12] <= 32'hc4600000; // store r3 in datamem[0] sw r3 r0 0
    mips2.mem[13] <= 32'hc0c00000; // load datamem[0] to r6 lw r6 r0 0
    mips2.mem[14] <= 32'h85000023; // r8 = r0 + 35
    mips2.mem[15] <= 32'h8d220002; // r9 = r2 * 2
    mips2.mem[16] <= 32'h0d430800; // r10 = r3 / r1
    mips2.mem[17] <= 32'h95650008; // r11 = r5 & 8
    mips2.mem[18] <= 32'hc4e00001; // sw r7 r0 1
    mips2.mem[19] <= 32'h1ff77800; // dummy
    mips2.mem[20] <= 32'h1ff77800; // dummy
    mips2.mem[21] <= 32'hfc000000;
    mips2.halted <= 0;
    mips2.pc <= 0;
    $monitor("r0 - %d",mips2.regb[0]);
    $monitor("r1 - %d",mips2.regb[1]);
    $monitor("r2 - %d",mips2.regb[2]);
    $monitor("r3 - %d",mips2.regb[3]);
    $monitor("r4 - %d",mips2.regb[4]);
    $monitor("r5 - %d",mips2.regb[5]); 
    $monitor("r6 - %d",mips2.regb[6]);
    $monitor("r7 - %d",mips2.regb[7]);
    $monitor("r8 - %d",mips2.regb[8]);
    $monitor("r9 - %d",mips2.regb[9]);
    $monitor("r10 - %d",mips2.regb[10]);
    $monitor("r11 - %d",mips2.regb[11]);
    
    $monitor($time, " op-cd = %b, A =%d, B =%d, IMM =%d, aluout =%d, datamem[0] =%d", mips2.id_ex_opcd, mips2.id_ex_a, mips2.id_ex_b, mips2.id_ex_imm, mips2.ex_mem_aluout, mips2.datamem[0]);
    #3000 $finish;
    end
    
    
    //Testing dynamic frequency scaling
    initial begin 
        temp_st <= temp_eq;
        #50 temp_st <= temp_small;
        #100 temp_st <= temp_lg;
        #150 temp_st <= temp_ext;
        #200 temp_st <= temp_eq;
        #250 temp_st <= temp_lg;
        end
        
endmodule
