//control unit
module control_unit
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    output logic                    branch,
    output logic                    pc_enable,
    output logic                    ir_enable,
    output logic                    write_reg_enable,
    output logic                    addr_sel,
    output logic                    c_sel,
    output logic              [1:0] operation,
    output logic                    flags_reg_enable,
    input  decoded_instruction_type decoded_instruction,
    input  logic                    zero_op,
    input  logic                    neg_op,
    input  logic                    unsigned_overflow,
    input  logic                    signed_overflow,
    output logic                    ram_write_enable,
    output logic                    halt
);

//registrador de estado
reg [3:0] state;
//codificacao dos estados
parameter s0  = 4'b0000,
          s1  = 4'b0001,
          s2  = 4'b0010,
          s3  = 4'b0011,
          s4  = 4'b0100,
          s5  = 4'b0101,
          s6  = 4'b0110,
          s7  = 4'b0111,
          s8  = 4'b1000,
          s9  = 4'b1001,
          s10 = 4'b1010,
          s11 = 4'b1011,
          s12 = 4'b1100;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= s0;
    end
    else begin
        case(state)
            //busca ram
            s0: begin
                addr_sel <= 'd0;
                c_sel <= 'd0;
                ir_enable <= 'd1;
                flags_reg_enable <= 'd0;
                pc_enable <= 'd0;
                write_reg_enable <= 'd0;
                halt <= 'd0;
                state <= s12;
            end
            //decode0
            s12: begin
                ir_enable <= 'd0;
                state <= s1;
            end
            
            //decode
            s1: begin
                //ir_enable <= 'd0;
                case(decoded_instruction)
                    I_LOAD: begin
                        state <= s2;
                    end
                    I_STORE: begin
                        state <= s6;
                    end
                    I_OR: begin
                        operation <= 2'b00;
                        state <= s7;
                    end
                    I_ADD: begin
                        operation <= 2'b01;
                        state <= s7;
                    end          
                    I_SUB: begin
                        operation <= 2'b10;
                        state <= s7;
                    end
                    I_AND: begin
                        operation <= 2'b11;
                        state <= s7;
                    end  
                    I_BRANCH: begin
                        state <= s8;
                    end
                    I_MOVE: begin
                        state <= s9;
                    end   
                    I_NOP: begin
                        state <= s10;
                    end 
                    I_HALT: begin
                        state <= s11;
                    end 
                    I_BNEG: begin
                        if(neg_op) begin
                            state <= s8;//vai para branch
                        end
                        else begin
                            state <= s4;//vai para proximo
                        end
                    end
                    I_BZERO: begin
                        if(zero_op) begin
                            state <= s8;//vai para branch
                        end
                        else begin
                            state <= s4;//vai para proximo
                        end
                    end                 
                endcase
            end
            //load1
            s2: begin
                ir_enable <= 'd0;
                flags_reg_enable <= 'd0;
                addr_sel <= 'd1;//pega valor mem_addr
                branch <= 'd1;
                halt <= 'd0;
                write_reg_enable <= 'd0;
                state <= s3;
            end
            //load2
            s3: begin
                c_sel<= 'd0;
                write_reg_enable <= 'd1;
                state <= s4;
            end
            //proximo1
            s4: begin
                ir_enable <= 'd0;
                flags_reg_enable <= 'd0;
                pc_enable <= 'd1;
                addr_sel <= 'd0;
                halt <= 'd0;
                write_reg_enable <= 'd0;
                ram_write_enable <= 'd0;
                state <= s5;
            end
            //proximo 2
            s5: begin
                branch <= 'd1;
                ir_enable <= 'd0;
                flags_reg_enable <= 'd0;
                pc_enable <= 'd0;
                halt <= 'd0;
                write_reg_enable <= 'd0;
                state <= s0;
            end
            //store
            s6: begin
                addr_sel <= 'd1;
                ram_write_enable <= 'd1;
                state <= s4;
            end
            //ula
            s7: begin
                c_sel <= 'd1;
                write_reg_enable <= 'd1;
                ir_enable <= 'd0;
                flags_reg_enable <= 'd1;
                state <= s4; 
            end 
            //branch  
            s8: begin
                branch <= 'd0;
                ir_enable <= 'd0;
                flags_reg_enable <= 'd0;
                addr_sel <= 'd1;
                state <= s4; 
            end  
            //move
            s9: begin
                ir_enable <= 'd0;
                flags_reg_enable <= 'd0;
                operation <= 'd0;
                c_sel <= 'd1;
                halt <= 'd0;
                write_reg_enable <= 'd1;
                state <= s4; 
            end 
            //nop
            s10: begin
                ir_enable <= 'd0;
                flags_reg_enable <= 'd0;
                branch <= 'd1;
                pc_enable <= 'd0;
                halt <= 'd0;
                write_reg_enable <= 'd0;
                state <= s4; 
            end 
            //halt
            s11: begin
                ir_enable <= 'd0;
                flags_reg_enable <= 'd0;
                branch <= 'd1;
                pc_enable <= 'd0;
                write_reg_enable <= 'd0;
                halt <= 'd1;
                state <= s11; 
            end
                    
        endcase
    end
end
endmodule : control_unit
