module risc_32_modify (temp_st, clk, clk1);
    input[2:0] temp_st;
    input clk;
    output reg clk1;
    reg[31:0] if_id_ir, pc;
    reg[31:0] id_ex_ir, id_ex_a, id_ex_b, id_ex_imm;
    reg[31:0] ex_mem_aluout, ex_mem_ir;
    reg[1:0] id_ex_type, ex_mem_type, mem_rb_type;
    reg[31:0] mem_rb_ir, mem_rb_aluout; 
    reg[31:0] regb[0:31];
    reg[31:0] mem[0:31], datamem[0:31];
    reg[5:0] id_ex_opcd, ex_mem_opcd;
    reg halted;
    integer del, temp1;
    
    parameter add = 6'b000000, sub = 6'b000001, mul = 6'b000010, div = 6'b000011, andr = 6'b000101, orr = 6'b000110, lsft = 6'b000100, addi = 6'b100001, subi = 6'b100010, muli = 6'b100011, divi = 6'b100100, andi = 6'b100101, ori = 6'b100110, halt = 6'b111111;
    parameter lw = 6'b110000, sw = 6'b110001;
    parameter rr_type = 2'b00, rm_type = 2'b01, ls_type = 2'b10;
    parameter temp_eq = 3'b000, temp_small = 3'b001, temp_lg = 3'b010, temp_ext = 3'b011;
    
    //Clock circuit
     initial begin
         clk1 <= 0;
         temp1 <= 1;
         del <= 1;
         end
     
     always @(posedge clk)
        if(halted == 1) clk1 <= 0;
        else if(temp1 < del)
            temp1 <= temp1 + 1;
        else if(temp1 >= del)
        begin
            temp1 <= 1;
            clk1 = ~clk1;
        end             
    
    
    
    always @(temp_st)
    begin
        case(temp_st)
        temp_eq : del <= 2;
        temp_small : del <= 2;
        temp_lg : del <= 4;
        temp_ext : del <= 8;
        endcase
    end
    
    //INSTRUCTION FETCH
    always @(posedge clk1)
        if(halted == 0)
            begin
            if_id_ir = mem[pc];
            pc = pc + 1;
            end
    
    //INSTRUCTION DECODE
    always @(posedge clk1)
        begin
        if(halted == 0)
            begin
            if(if_id_ir[31:26] == 6'b111111)
            halted <= 1;
            if(if_id_ir[31:30] == 2'b00)
            id_ex_type <= rr_type;
            if(if_id_ir[31:30] == 2'b10)
            id_ex_type <= rm_type;
            if(if_id_ir[31:30] == 2'b11)
            id_ex_type <= ls_type;
            end
        id_ex_ir <= if_id_ir;
        id_ex_a <= regb[if_id_ir[20:16]];
        id_ex_b <= regb[if_id_ir[15:11]];
        id_ex_imm <= if_id_ir[15:0];
        id_ex_opcd <= if_id_ir[31:26];
        end

        
    //INSTRUCTION EXECUTE
    always @(posedge clk1)
        begin
        if(halted == 0)
            begin
            case(id_ex_type)
            rr_type : begin
                      case(id_ex_opcd)
                          add : ex_mem_aluout <= id_ex_a + id_ex_b;
                          sub : ex_mem_aluout <= id_ex_a - id_ex_b;
                          mul : ex_mem_aluout <= id_ex_a * id_ex_b;
                          div : ex_mem_aluout <= id_ex_a / id_ex_b;
                          andr : ex_mem_aluout <= id_ex_a & id_ex_b;
                          orr : ex_mem_aluout <= id_ex_a | id_ex_b;
                          lsft : ex_mem_aluout <= id_ex_a << id_ex_b;
                          default : ex_mem_aluout <= 8'h00000000;
                      endcase
                      end
            
            rm_type : begin
                      case(id_ex_opcd)
                          addi : ex_mem_aluout <= id_ex_a + id_ex_imm;
                          subi : ex_mem_aluout <= id_ex_a - id_ex_imm;
                          muli : ex_mem_aluout <= id_ex_a * id_ex_imm;
                          divi : ex_mem_aluout <= id_ex_a / id_ex_imm;
                          andi : ex_mem_aluout <= id_ex_a & id_ex_imm;
                          ori : ex_mem_aluout <= id_ex_a & id_ex_imm;
                          default : ex_mem_aluout <= 8'h00000000;
                      endcase
                      end
            
            ls_type : begin
                      case(id_ex_opcd)
                          sw : ex_mem_aluout <= id_ex_a + id_ex_imm;
                          lw : ex_mem_aluout <= id_ex_a + id_ex_imm;
                      endcase
                      end
            default : ex_mem_aluout <= 8'h00000000;
            endcase
            end
        ex_mem_ir <= id_ex_ir;
        ex_mem_type <= id_ex_type;
        ex_mem_opcd <= id_ex_opcd;
        end
        
    //MEMORY STORAGE
    //always @(posedge clk1)
    //    begin
    //    if(halted == 0)
    //        begin
    //        mem_rb_ir <= ex_mem_ir;
    //        mem_rb_type <= ex_mem_type;
    //        if(ex_mem_opcd == lw) mem_rb_aluout <= datamem[ex_mem_aluout];
    //        else if(ex_mem_opcd == sw) datamem[ex_mem_aluout] <= regb[ex_mem_ir[25:21]];
    //        else mem_rb_aluout <= ex_mem_aluout;
    //        end
    //    end
        
    //WRITE BACK
    //always @(posedge clk1)
    //    begin
    //    if(halted == 0)
    //        if(mem_rb_ir[31:26] != 6'b110001)
    //        regb[mem_rb_ir[25:21]] <= mem_rb_aluout;
    //    end
    
    
    // MEM / WB
    always @(posedge clk1)
    begin
        if(halted == 0)
        mem_rb_ir <= ex_mem_ir;
        mem_rb_type <= ex_mem_type;
        case(ex_mem_opcd)
        sw : datamem[ex_mem_aluout] <= regb[ex_mem_ir[25:21]];
        lw : mem_rb_aluout <= datamem[ex_mem_aluout];
        default : regb[ex_mem_ir[25:21]] <= ex_mem_aluout;
        endcase
    end       
    
    //WB - LW
    always @(posedge clk1)
    begin
        if(halted == 0)
        if(mem_rb_ir[31:26] == lw)
        regb[mem_rb_ir[25:21]] <= mem_rb_aluout;
    end
            
endmodule
        

                   
          
                        
            
            
    
        