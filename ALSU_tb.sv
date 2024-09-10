module ALSU_tb;

import process::*;

parameter ITERATION = 1000;
inputs mm = new();

logic clk, rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
logic [2:0] opcode;
logic signed [2:0] A, B;
wire [15:0] leds_1,leds_2;
wire [5:0] out_1,out_2;
int ERROR_COUNT,CORRECT_COUNT;

ALSU dut1 (A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, clk, rst, direction, leds_1, out_1);
ALSU_GM dut2 (clk,rst,A,B,cin,serial_in,red_op_A,red_op_B,opcode,bypass_A,bypass_B,direction,leds_2,out_2);

initial begin
    clk = 0;
    forever #1 clk =~ clk;
end

initial begin
    ERROR_COUNT = 0;
    CORRECT_COUNT = 0;
    assert_reset();                            //LABEL 1
    mm.cvr_gb.start();
    mm.fixed_array.constraint_mode(0);
    randomdata_first_loop();                              //LABEL 2
    mm.constraint_mode(0);
    rst      = 0;
    bypass_A = 0;
    bypass_B = 0;
    red_op_A = 0;
    red_op_B = 0;
    mm.fixed_array.constraint_mode(1);
    randomdata_second_loop();
    mm.constraint_mode(1);
    mm.fixed_array.constraint_mode(0);
    cover_transition(); //to achieve 100% functional coverage of transition bin  
    display_results();
    $stop;
end

task randomdata_first_loop();
    for (int i =0 ; i < ITERATION ; i++ ) begin     
        assert(mm.randomize);
        rst       =mm.rst ; 
        cin       =mm.cin ; 
        red_op_A  =mm.red_op_A ; 
        red_op_B  =mm.red_op_B ; 
        bypass_A  =mm.bypass_A ; 
        bypass_B  =mm.bypass_B ; 
        direction =mm.direction ; 
        serial_in =mm.serial_in ;
        opcode    =mm.opcode ;
        A         =mm.A ; 
        B         =mm.B ;
        sample_task();
        check_result();
    end
endtask

task randomdata_second_loop();
    for (int i =0 ; i < ITERATION ; i++ ) begin     
        assert(mm.randomize); 
        cin       =mm.cin ;  
        direction =mm.direction ; 
        serial_in =mm.serial_in ;
        A         =mm.A ; 
        B         =mm.B ;
        for (int count = 0 ; count < 6 ; count++) begin
            opcode    =mm.arr[count] ;
            sample_task();
            check_result();
        end
    end
endtask

task display_results();
    $display("ERROR CASES = %d ,VALID CASES = %d",ERROR_COUNT,CORRECT_COUNT);
endtask

task assert_reset();
        rst = 1;
        check_result();
        rst = 0;
endtask

task sample_task();
    mm.cvr_gb.start();
    $display("Sampling: rst=%b, bypass_A=%b, bypass_B=%b, opcode=%b, A=%b, B=%b", 
             rst, bypass_A, bypass_B, mm.opcode, mm.A, mm.B);
    if (rst || bypass_A || bypass_B) begin
        $display("Coverage sampling stopped due to reset or bypass signals being asserted.");
        mm.cvr_gb.stop();
    end else begin
        $display("sampled");
        mm.cvr_gb.sample();
    end
endtask

task cover_transition();
        assert(mm.randomize()with{opcode == 0;});
        cin       =mm.cin ;  
        direction =mm.direction ; 
        serial_in =mm.serial_in ;
        A         =mm.A ; 
        B         =mm.B ;
        sample_task();
        check_result();
        assert(mm.randomize()with{opcode == 1;});
        sample_task();
        check_result();
        assert(mm.randomize()with{opcode == 2;});
        sample_task();
        check_result();
        assert(mm.randomize()with{opcode == 3;});
        sample_task();
        check_result();
        assert(mm.randomize()with{opcode == 4;});
        sample_task();
        check_result();
        assert(mm.randomize()with{opcode == 5;});
        sample_task();
        check_result();
endtask

task check_result();
        @(negedge clk);
        @(negedge clk);
        if(out_1 != out_2 || leds_1 != leds_2) begin
            $display("Invalid output expected out =%d , returned %d ,expected leds = %d , returned %d",out_2,out_1,leds_2,leds_1);
            ERROR_COUNT = ERROR_COUNT + 1;
            $display("A = %b , B = %b , op code = %b , cin = %b , red_op_A = %b , red_op_B = %b , bypass_A = %b , bypass_B = %b , direction = %b , serial_in = %b , out_1 = %b , out_2 = %b , leds_1 = %b , leds_2 = %b",dut2.A_reg,dut2.B_reg,dut2.opcode_reg,dut2.Cin_reg,dut2.red_op_A_reg,dut2.red_op_B_reg,dut2.bypass_A_reg,dut2.bypass_B_reg,dut2.direction_reg,dut2.serial_in_reg,out_1,out_2,leds_1,leds_2);
        end
        else begin
            $display("Valid Output");
            CORRECT_COUNT = CORRECT_COUNT+1;
            $display("A = %b , B = %b , op code = %b , cin = %b , red_op_A = %b , red_op_B = %b , bypass_A = %b , bypass_B = %b , direction = %b , serial_in = %b , out_1 = %b , out_2 = %b , leds_1 = %b , leds_2 = %b",dut2.A_reg,dut2.B_reg,dut2.opcode_reg,dut2.Cin_reg,dut2.red_op_A_reg,dut2.red_op_B_reg,dut2.bypass_A_reg,dut2.bypass_B_reg,dut2.direction_reg,dut2.serial_in_reg,out_1,out_2,leds_1,leds_2);
        end
endtask
endmodule