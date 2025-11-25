module Systolic_Array
#(
    parameter WIDTH = 8, // width
    parameter ARRAY_SIZE = 4 // row num & col num
)
(
    input clk,
    input rst,
    input en,
    input [WIDTH*ARRAY_SIZE*ARRAY_SIZE-1:0] in1,
    input [WIDTH*ARRAY_SIZE*ARRAY_SIZE-1:0] in2,
    output reg [(2*WIDTH+2)*(ARRAY_SIZE*ARRAY_SIZE)-1:0] result
);

reg signed [WIDTH-1:0] row [ARRAY_SIZE-1:0][2*ARRAY_SIZE-1:0];
reg signed [WIDTH-1:0] col [ARRAY_SIZE-1:0][2*ARRAY_SIZE-1:0];

wire signed [WIDTH-1:0] down [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
wire signed [WIDTH-1:0] right [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
wire signed [2*WIDTH+1:0] sum [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];

reg signed [WIDTH-1:0] left [ARRAY_SIZE-1:0];
reg signed [WIDTH-1:0] up [ARRAY_SIZE-1:0];

reg [3:0] flag;

always @(posedge clk) begin
    if(rst) begin
        result <= 0;
    end
    else begin
        // row[0]
        row[0][0] <= in1[(1*WIDTH-1)-:WIDTH];
        row[0][1] <= in1[(2*WIDTH-1)-:WIDTH];
        row[0][2] <= in1[(3*WIDTH-1)-:WIDTH];
        row[0][3] <= in1[(4*WIDTH-1)-:WIDTH];
        row[0][4] <= {WIDTH{1'b0}};
        row[0][5] <= {WIDTH{1'b0}};
        row[0][6] <= {WIDTH{1'b0}};

        // row[1]
        row[1][0] <= {WIDTH{1'b0}};
        row[1][1] <= in1[(5*WIDTH-1)-:WIDTH];
        row[1][2] <= in1[(6*WIDTH-1)-:WIDTH];
        row[1][3] <= in1[(7*WIDTH-1)-:WIDTH];
        row[1][4] <= in1[(8*WIDTH-1)-:WIDTH];
        row[1][5] <= {WIDTH{1'b0}};
        row[1][6] <= {WIDTH{1'b0}};
        
        // row[2]
        row[2][0] <= {WIDTH{1'b0}};
        row[2][1] <= {WIDTH{1'b0}};
        row[2][2] <= in1[(9*WIDTH-1)-:WIDTH];
        row[2][3] <= in1[(10*WIDTH-1)-:WIDTH];
        row[2][4] <= in1[(11*WIDTH-1)-:WIDTH];
        row[2][5] <= in1[(12*WIDTH-1)-:WIDTH];
        row[2][6] <= {WIDTH{1'b0}};

        // row[3]
        row[3][0] <= {WIDTH{1'b0}};
        row[3][1] <= {WIDTH{1'b0}};
        row[3][2] <= {WIDTH{1'b0}};
        row[3][3] <= in1[(13*WIDTH-1)-:WIDTH];
        row[3][4] <= in1[(14*WIDTH-1)-:WIDTH];
        row[3][5] <= in1[(15*WIDTH-1)-:WIDTH];
        row[3][6] <= in1[(16*WIDTH-1)-:WIDTH];

        // col[0]
        col[0][0] <= in2[(1*WIDTH-1)-:WIDTH];
        col[0][1] <= in2[(5*WIDTH-1)-:WIDTH];
        col[0][2] <= in2[(9*WIDTH-1)-:WIDTH];
        col[0][3] <= in2[(13*WIDTH-1)-:WIDTH];
        col[0][4] <= {WIDTH{1'b0}};
        col[0][5] <= {WIDTH{1'b0}};
        col[0][6] <= {WIDTH{1'b0}};
        
        // col[1]
        col[1][0] <= {WIDTH{1'b0}};
        col[1][1] <= in2[(2*WIDTH-1)-:WIDTH];
        col[1][2] <= in2[(6*WIDTH-1)-:WIDTH];
        col[1][3] <= in2[(10*WIDTH-1)-:WIDTH];
        col[1][4] <= in2[(14*WIDTH-1)-:WIDTH];
        col[1][5] <= {WIDTH{1'b0}};
        col[1][6] <= {WIDTH{1'b0}};
        
        // col[2]
        col[2][0] <= {WIDTH{1'b0}};
        col[2][1] <= {WIDTH{1'b0}};
        col[2][2] <= in2[(3*WIDTH-1)-:WIDTH];
        col[2][3] <= in2[(7*WIDTH-1)-:WIDTH];
        col[2][4] <= in2[(11*WIDTH-1)-:WIDTH];
        col[2][5] <= in2[(15*WIDTH-1)-:WIDTH];
        col[2][6] <= {WIDTH{1'b0}};

        // col[3]
        col[3][0] <= {WIDTH{1'b0}};
        col[3][1] <= {WIDTH{1'b0}};
        col[3][2] <= {WIDTH{1'b0}};
        col[3][3] <= in2[(4*WIDTH-1)-:WIDTH];
        col[3][4] <= in2[(8*WIDTH-1)-:WIDTH];
        col[3][5] <= in2[(12*WIDTH-1)-:WIDTH];
        col[3][6] <= in2[(16*WIDTH-1)-:WIDTH];
    end
end

always @(posedge clk) begin
    if(rst) begin
        flag <= 0;
    end
    else if(en) begin
        if(flag < 11) begin
            flag <= flag + 1;
        end
        else begin
            flag <= flag;
        end
    end
end

always @(posedge clk) begin
    case(flag)
        0: begin
            left[0]  <= row[0][0];
            left[1]  <= row[1][0];
            left[2]  <= row[2][0];
            left[3]  <= row[3][0];
            up[0]    <= col[0][0];
            up[1]    <= col[1][0];
            up[2]    <= col[2][0];
            up[3]    <= col[3][0];
        end
        1: begin
            left[0]  <= row[0][1];
            left[1]  <= row[1][1];
            left[2]  <= row[2][1];
            left[3]  <= row[3][1];
            up[0]    <= col[0][1];
            up[1]    <= col[1][1];
            up[2]    <= col[2][1];
            up[3]    <= col[3][1];
        end
        2: begin
            left[0]  <= row[0][2];
            left[1]  <= row[1][2];
            left[2]  <= row[2][2];
            left[3]  <= row[3][2];
            up[0]    <= col[0][2];
            up[1]    <= col[1][2];
            up[2]    <= col[2][2];
            up[3]    <= col[3][2];
        end
        3: begin
            left[0]  <= row[0][3];
            left[1]  <= row[1][3];
            left[2]  <= row[2][3];
            left[3]  <= row[3][3];
            up[0]    <= col[0][3];
            up[1]    <= col[1][3];
            up[2]    <= col[2][3];
            up[3]    <= col[3][3];
        end
        4: begin
            left[0]  <= row[0][4];
            left[1]  <= row[1][4];
            left[2]  <= row[2][4];
            left[3]  <= row[3][4];
            up[0]    <= col[0][4];
            up[1]    <= col[1][4];
            up[2]    <= col[2][4];
            up[3]    <= col[3][4];
        end
        5: begin
            left[0]  <= row[0][5];
            left[1]  <= row[1][5];
            left[2]  <= row[2][5];
            left[3]  <= row[3][5];
            up[0]    <= col[0][5];
            up[1]    <= col[1][5];
            up[2]    <= col[2][5];
            up[3]    <= col[3][5];
        end
        6: begin
            left[0]  <= row[0][6];
            left[1]  <= row[1][6];
            left[2]  <= row[2][6];
            left[3]  <= row[3][6];
            up[0]    <= col[0][6];
            up[1]    <= col[1][6];
            up[2]    <= col[2][6];
            up[3]    <= col[3][6];
        end
        11: begin
            left[0]  <= 0;
            left[1]  <= 0;
            left[2]  <= 0;
            left[3]  <= 0;
            up[0]    <= 0;
            up[1]    <= 0;
            up[2]    <= 0;
            up[3]    <= 0;
            // result <= {sum[0][0], sum[0][1], sum[0][2], sum[0][3], sum[1][0], sum[1][1], sum[1][2], sum[1][3], sum[2][0], sum[2][1], sum[2][2], sum[2][3], sum[3][0], sum[3][1], sum[3][2], sum[3][3]};
            result <= {sum[3][3], sum[3][2], sum[3][1], sum[3][0], sum[2][3], sum[2][2], sum[2][1], sum[2][0], sum[1][3], sum[1][2], sum[1][1], sum[1][0], sum[0][3], sum[0][2], sum[0][1], sum[0][0]};
        end

        default: begin
            left[0]  <= 0;
            left[1]  <= 0;
            left[2]  <= 0;
            left[3]  <= 0;
            up[0]    <= 0;
            up[1]    <= 0;
            up[2]    <= 0;
            up[3]    <= 0;
        end
    endcase
end

Processing_Element u_Processing_Element_00(
    .clk    (clk),
    .rst    (rst),
    .left   (left[0]),
    .up     (up[0]),
    .down   (down[0][0]),
    .right  (right[0][0]),
    .sum_out(sum[0][0])
);

Processing_Element u_Processing_Element_01(
    .clk    (clk),
    .rst    (rst),
    .left   (right[0][0]),
    .up     (up[1]),
    .down   (down[0][1]),
    .right  (right[0][1]),
    .sum_out(sum[0][1])
);

Processing_Element u_Processing_Element_02(
    .clk    (clk),
    .rst    (rst),
    .left   (right[0][1]),
    .up     (up[2]),
    .down   (down[0][2]),
    .right  (right[0][2]),
    .sum_out(sum[0][2])
);

Processing_Element u_Processing_Element_03(
    .clk    (clk),
    .rst    (rst),
    .left   (right[0][2]),
    .up     (up[3]),
    .down   (down[0][3]),
    .right  (right[0][3]),
    .sum_out(sum[0][3])
);

Processing_Element u_Processing_Element_10(
    .clk    (clk),
    .rst    (rst),
    .left   (left[1]),
    .up     (down[0][0]),
    .down   (down[1][0]),
    .right  (right[1][0]),
    .sum_out(sum[1][0])
);

Processing_Element u_Processing_Element_11(
    .clk    (clk),
    .rst    (rst),
    .left   (right[1][0]),
    .up     (down[0][1]),
    .down   (down[1][1]),
    .right  (right[1][1]),
    .sum_out(sum[1][1])
);

Processing_Element u_Processing_Element_12(
    .clk    (clk),
    .rst    (rst),
    .left   (right[1][1]),
    .up     (down[0][2]),
    .down   (down[1][2]),
    .right  (right[1][2]),
    .sum_out(sum[1][2])
);

Processing_Element u_Processing_Element_13(
    .clk    (clk),
    .rst    (rst),
    .left   (right[1][2]),
    .up     (down[0][3]),
    .down   (down[1][3]),
    .right  (right[1][3]),
    .sum_out(sum[1][3])
);

Processing_Element u_Processing_Element_20(
    .clk    (clk),
    .rst    (rst),
    .left   (left[2]),
    .up     (down[1][0]),
    .down   (down[2][0]),
    .right  (right[2][0]),
    .sum_out(sum[2][0])
);

Processing_Element u_Processing_Element_21(
    .clk    (clk),
    .rst    (rst),
    .left   (right[2][0]),
    .up     (down[1][1]),
    .down   (down[2][1]),
    .right  (right[2][1]),
    .sum_out(sum[2][1])
);

Processing_Element u_Processing_Element_22(
    .clk    (clk),
    .rst    (rst),
    .left   (right[2][1]),
    .up     (down[1][2]),
    .down   (down[2][2]),
    .right  (right[2][2]),
    .sum_out(sum[2][2])
);

Processing_Element u_Processing_Element_23(
    .clk    (clk),
    .rst    (rst),
    .left   (right[2][2]),
    .up     (down[1][3]),
    .down   (down[2][3]),
    .right  (right[2][3]),
    .sum_out(sum[2][3])
);

Processing_Element u_Processing_Element_30(
    .clk    (clk),
    .rst    (rst),
    .left   (left[3]),
    .up     (down[2][0]),
    .down   (down[3][0]),
    .right  (right[3][0]),
    .sum_out(sum[3][0])
);

Processing_Element u_Processing_Element_31(
    .clk    (clk),
    .rst    (rst),
    .left   (right[3][0]),
    .up     (down[2][1]),
    .down   (down[3][1]),
    .right  (right[3][1]),
    .sum_out(sum[3][1])
);

Processing_Element u_Processing_Element_32(
    .clk    (clk),
    .rst    (rst),
    .left   (right[3][1]),
    .up     (down[2][2]),
    .down   (down[3][2]),
    .right  (right[3][2]),
    .sum_out(sum[3][2])
);

Processing_Element u_Processing_Element_33(
    .clk    (clk),
    .rst    (rst),
    .left   (right[3][2]),
    .up     (down[2][3]),
    .down   (down[3][3]),
    .right  (right[3][3]),
    .sum_out(sum[3][3])
);

endmodule