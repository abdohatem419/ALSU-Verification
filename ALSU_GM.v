module ALSU_GM(clk,rst,A,B,Cin,serial_in,red_op_A,red_op_B,opcode,bypass_A,bypass_B,direction,leds,out);
/*Ports declaration*/
input clk,rst,serial_in,red_op_A,red_op_B,bypass_A,bypass_B,direction;
input signed Cin;
input signed [2:0]A,B;
input [2:0] opcode;
output reg [15:0]leds;
output  reg signed [5:0]out;
/*Internal signals*/
reg Cin_reg,serial_in_reg,red_op_A_reg,red_op_B_reg,bypass_A_reg,bypass_B_reg,direction_reg;
reg [2:0]A_reg,B_reg,opcode_reg;
/*Parameters definitions*/
parameter INPUT_PRIORITY ="A" ;
parameter FULL_ADDER="ON";


always@(posedge clk or posedge rst)begin
    if(rst)begin
        serial_in_reg<=0;
        red_op_A_reg <=0;
        red_op_B_reg <=0;
        bypass_A_reg <=0;
        bypass_B_reg <=0;
        direction_reg<=0;
        A_reg        <=0;
        B_reg        <=0;   
        opcode_reg   <=0;
        Cin_reg      <=0;
    end
    else begin
        serial_in_reg<=serial_in;
        red_op_A_reg <=red_op_A;
        red_op_B_reg <=red_op_B;
        bypass_A_reg <=bypass_A;
        bypass_B_reg <=bypass_B;
        direction_reg<=direction;
        A_reg        <=A;
        B_reg        <=B;   
        opcode_reg   <=opcode;
        Cin_reg      <=Cin;
    end
end

/*main functionality*/
always@(posedge clk or posedge rst)begin
    if(rst)begin
        leds         <=0;
        out          <=0;
    end
    else begin
        if((opcode_reg==3'b110||opcode_reg==3'b111)||((red_op_A_reg==1||red_op_B_reg==1)&&(opcode_reg!=3'b000&&opcode_reg!=3'b001)))begin
            leds<=leds^16'hFFFF;
            out<=0;
        end
        else if(bypass_A_reg||bypass_B_reg) begin
            if(bypass_A_reg&&bypass_B_reg)begin
                if(INPUT_PRIORITY == "A" )begin
                    out<=A_reg;
                end
                else if(INPUT_PRIORITY == "B")begin
                    out<=B_reg;
                end
            end
            else if(bypass_A_reg)begin
                out<=A_reg;
            end
            else if(bypass_B_reg)begin
                out<=B_reg;
            end
    end
    else begin
        case (opcode_reg)
            3'b000:begin
                if(red_op_A_reg||red_op_B_reg)begin
                    if(red_op_A_reg&&red_op_B_reg)begin
                        if(INPUT_PRIORITY=="A")out<=|A_reg;
                        else if(INPUT_PRIORITY=="B")out<=|B_reg;
                    end
                     else if(red_op_A)out<=|A_reg;
                     else if(red_op_B)out<=|B_reg;
                end
                else begin
                    out<=A_reg|B_reg;
                end
            end
            3'b001:begin
                if(red_op_A_reg||red_op_B_reg)begin
                    if(red_op_A_reg&&red_op_B_reg)begin
                        if(INPUT_PRIORITY=="A")out<=^A_reg;
                        else if(INPUT_PRIORITY=="B")out<=^B_reg;
                    end
                     else if(red_op_A)out<=^A_reg;
                     else if(red_op_B)out<=^B_reg;
                end
                else begin
                    out<=A_reg^B_reg;
                end
            end
            3'b010:begin
                     if(FULL_ADDER=="ON")begin
                        out<=A_reg+B_reg+Cin_reg;
                     end
                     else if(FULL_ADDER=="OFF")begin
                        out<=A_reg+B_reg;
                     end   
            end
            3'b011:begin
                out<=A_reg*B_reg;
            end
            3'b100:begin
                     if(direction_reg)begin
                        out<={out[4:0],serial_in_reg};
                     end
                     else begin
                        out<={serial_in_reg,out[5:1]};
                     end
            end
            3'b101:begin
                     if(direction_reg)begin
                        out<={out[4:0],out[5]};
                     end
                     else begin
                        out<={out[0],out[5:1]};
                     end
            end 
        endcase
        
    end
end
end
endmodule