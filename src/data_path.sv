module data_path
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    input  logic                    branch,
    input  logic                    pc_enable,
    input  logic                    ir_enable,
    input  logic                    addr_sel,
    input  logic                    c_sel,
    input  logic              [1:0] operation,
    input  logic                    write_reg_enable,
    input  logic                    flags_reg_enable,
    output decoded_instruction_type decoded_instruction,
    output logic                    zero_op,
    output logic                    neg_op,
    output logic                    unsigned_overflow,
    output logic                    signed_overflow,
    output logic              [4:0] ram_addr,
    output logic             [15:0] data_out,
    input  logic             [15:0] data_in

);

logic [4:0] pc = 'd0;
logic [4:0] mem_addr;
logic [15:0] instruction;
//logic [1:0] a_addr = 'd0;
//logic [1:0] b_addr = 'd0;
//logic [1:0] c_addr = 'd0;
logic [1:0] a_addr;
logic [1:0] b_addr;
logic [1:0] c_addr;
logic [15:0] bus_a;
logic [15:0] bus_b;
logic [15:0] bus_c;
logic [15:0] ula_out;
//reg [15:0] r0,r1,r2,r4;
reg [15:0] r0;
reg [15:0] r1;
reg [15:0] r2;
reg [15:0] r3;

//pc 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        pc <= 'd0;
    else if(pc_enable)
        if(~branch)
            pc <= mem_addr;
        else
            pc <= pc+1;      
end

//mux_ram 
always_comb begin
    if(~addr_sel)
        ram_addr <= pc;
    else
        ram_addr <= mem_addr;
end

//ir 
always @(posedge clk) begin
    if(ir_enable) begin
        instruction<= data_in;
    end
end

//decode 
always_comb begin
    a_addr   <= 'd0;
    b_addr   <= 'd0;
    c_addr   <= 'd0;
    mem_addr <= instruction[4:0];
    
    case(instruction[15:8])
        //add
        8'b10100001: begin
            decoded_instruction <= I_ADD;
            b_addr <= instruction[1:0];
            a_addr <= instruction[3:2];
            c_addr <= instruction[5:4]; 
        end
        //sub
        8'b10100010: begin
            decoded_instruction <= I_SUB;
            b_addr <= instruction[1:0];
            a_addr <= instruction[3:2];
            c_addr <= instruction[5:4];   
        end
        //and
        8'b10100011: begin
            decoded_instruction <= I_AND;
            b_addr <= instruction[1:0];
            a_addr <= instruction[3:2];
            c_addr <= instruction[5:4]; 
        end            
        //or
        8'b10100100: begin
            decoded_instruction <= I_OR;
            b_addr <= instruction[1:0];
            a_addr <= instruction[3:2];
            c_addr <= instruction[5:4]; 
        end  
        //load
        8'b10000001: begin
            decoded_instruction <= I_LOAD;
            c_addr <= instruction[6:5];
            mem_addr <= instruction[4:0];
        end
        //store
        8'b10000010: begin
            decoded_instruction <= I_STORE;
            a_addr <= instruction[6:5];
            c_addr <= instruction[6:5];
            mem_addr <= instruction[4:0];
        end
        //move
        8'b10010001: begin
            decoded_instruction <= I_MOVE;
            a_addr <= instruction[1:0];
            b_addr <= instruction[1:0];
            c_addr <= instruction[3:2]; 
        end 
        //branch
        8'b00000001: begin
            decoded_instruction <= I_BRANCH;
            mem_addr <= instruction[4:0];
        end        
        //bzero
        8'b00000010: begin
            decoded_instruction <= I_BZERO;
            mem_addr <= instruction[4:0];
        end         
        //bneg
        8'b00000011: begin
            decoded_instruction <= I_BNEG;
            mem_addr <= instruction[4:0];
        end          
        //halt
        8'b11111111: begin
            decoded_instruction <= I_HALT;
        end
        //nop
        8'b00000000: begin
            decoded_instruction <= I_NOP;
        end      
    endcase
end

//escrita banco de registradores
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r0 <= 'd0;
        r1 <= 'd0;
        r2 <= 'd0;
        r3 <= 'd0;
    end
    else if(write_reg_enable) begin
    /*
        case(a_addr)
            2'b00: r0 <= bus_a;
            2'b01: r1 <= bus_a;
            2'b10: r2 <= bus_a;
            2'b11: r3 <= bus_a;
        endcase
        
        case(b_addr)
            2'b00: r0 <= bus_b;
            2'b01: r1 <= bus_b;
            2'b10: r2 <= bus_b;
            2'b11: r3 <= bus_b;
        endcase
 */       
        case(c_addr)
            2'b00: r0 <= bus_c;
            2'b01: r1 <= bus_c;
            2'b10: r2 <= bus_c;
            2'b11: r3 <= bus_c;
        endcase
    end
end

//leitura banco de registradores
always_comb begin
        case(a_addr)
            2'b00: bus_a <= r0;
            2'b01: bus_a <= r1;
            2'b10: bus_a <= r2;
            2'b11: bus_a <= r3;
        endcase
        
        case(b_addr)
            2'b00: bus_b <= r0;
            2'b01: bus_b <= r1;
            2'b10: bus_b <= r2;
            2'b11: bus_b <= r3;
        endcase
 
end

//ula
always_comb begin
//always @(bus_a or bus_b or operation) begin
    data_out <= bus_a;
    case(operation)
        2'b00: ula_out <= bus_a | bus_b;//or
        2'b01: ula_out <= bus_a + bus_b;//add
        2'b10: ula_out <= bus_a - bus_b;//sub
        2'b11: ula_out <= bus_a & bus_b;//and
    endcase
    
end

//mux_ula
always_comb begin
    if(~c_sel)
        bus_c <= data_in;
    else
        bus_c <= ula_out;
end

//flags
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        zero_op <= 'd0;
        neg_op <= 'd0;
        unsigned_overflow <= 'd0;
        signed_overflow <= 'd0;
    end
    else if(flags_reg_enable) begin
        //zero
        if(ula_out=='d0) begin
            zero_op <= 'd1;
        end
        else begin
            zero_op <= 'd0;
        end
        
        //neg
        if(ula_out[15]=='d1) begin
            neg_op <= 'd1;
        end
        else begin
            neg_op <= 'd0;
        end
        
        //unsigned_overflow
        if((bus_a[15]=='d1 & bus_b[15]=='d1) | (bus_c[15]=='d0 & (bus_a[15]=='d0 ^ bus_b[15]=='d1)))begin
            unsigned_overflow <= 'd1;
        end
        else begin
            unsigned_overflow <= 'd0;
        end 
        
        //signed_overflow
        if((bus_a[15]=='d0 & bus_b[15]=='d0 & bus_c[15]=='d0) | (bus_a[15]=='d0 & bus_b[15]=='d0 & bus_c[15]=='d1)) begin
            signed_overflow <= 'd1;
        end
        else begin
            signed_overflow <= 'd0;
        end 
    end
end

endmodule : data_path
