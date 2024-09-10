package process;

typedef enum  {
    OR,
    XOR,
    ADD,
    MULT,
    SHIFT,
    ROTATE,
    INVALID_6,
    INVALID_7
  } opcode_e;

localparam  MAXPOS=  3;
localparam  MAXNEG= -4;
localparam  ZERO  =  0;

class inputs;

    rand bit rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
    rand opcode_e opcode;
    rand bit [2:0] A, B;
    rand opcode_e arr[6];

    constraint rs {
        rst dist {
            0:=80,
            1:=20
        };
    }
    constraint a{
        if(opcode == ADD || opcode == MULT)
            A dist{
                MAXPOS := 30,
                MAXNEG := 30,
                ZERO   := 30
            };
        else if((opcode == OR||opcode == XOR )&&(red_op_A))
            A dist{
                1:=30,
                2:=30,
                4:=30
            };
        else if((opcode == OR||opcode == XOR )&&(red_op_B))
            A dist{
                MAXPOS := 0,
                MAXNEG := 0,
                ZERO   := 30
            };
    }
    constraint b{
        if(opcode == ADD || opcode == MULT)
            B dist{
                MAXPOS := 30,
                MAXNEG := 30,
                ZERO   := 30
            };
        else if((opcode == OR||opcode == XOR )&&(red_op_A))
            B dist{
                MAXPOS := 0,
                MAXNEG := 0,
                ZERO   := 30
            };
        else if((opcode == OR||opcode == XOR )&&(red_op_B))
            B dist{
                1:=30,
                2:=30,
                4:=30
            };
    }
    constraint op{
        opcode dist{
            OR        := 50,
            XOR       := 50,
            ADD       := 50,
            MULT      := 50,
            SHIFT     := 50,
            ROTATE    := 50,
            INVALID_6 := 5,
            INVALID_7 := 5
        };
    }
    constraint bypass{
        bypass_A dist{
            0:=80,
            1:=10
        };
        bypass_B dist{
            0:=80,
            1:=10
        };
    }
    constraint fixed_array {
    // Ensure that each element of the array is within the valid range
        foreach(arr[i]) {
            arr[i] inside {[0:5]};
            foreach(arr[j]){
                if(i!=j) arr[i] != arr[j];
            }
        }
    }

    covergroup cvr_gb;
        A_cp : coverpoint A {
            bins A_data_0 = {ZERO};
            bins A_data_max={MAXPOS};
            bins A_data_min={MAXNEG};
            bins A_data_walkingones[]={001, 010, 100} iff(red_op_A) ;
            bins A_data_default=default;
        }
        B_cp : coverpoint B {
            bins B_data_0 = {ZERO};
            bins B_data_max={MAXPOS};
            bins B_data_min={MAXNEG};
            bins B_data_walkingones[]={001, 010, 100} iff(!red_op_A && red_op_B) ;
            bins B_data_default=default;
        }
        ALU_cp : coverpoint opcode {
            bins Bins_shift[] = {SHIFT,ROTATE};
            bins Bins_arith[] = {ADD,MULT};
            bins Bins_bitwise[] = {OR,XOR};
            illegal_bins Bins_invalid = {INVALID_6,INVALID_7};
            bins Bins_trans = (OR => XOR => ADD => MULT => SHIFT => ROTATE);
        }
    endgroup

    function new();
        cvr_gb = new();
    endfunction

endclass

endpackage