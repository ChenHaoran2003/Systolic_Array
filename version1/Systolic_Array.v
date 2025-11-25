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
    output reg [(2*WIDTH+$clog2(ARRAY_SIZE))*(ARRAY_SIZE*ARRAY_SIZE)-1:0] result
);

reg signed [WIDTH-1:0] row [ARRAY_SIZE-1:0][2*ARRAY_SIZE-1:0];
reg signed [WIDTH-1:0] col [ARRAY_SIZE-1:0][2*ARRAY_SIZE-1:0];

wire signed [WIDTH-1:0] down [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
wire signed [WIDTH-1:0] right [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
wire signed [2*WIDTH+$clog2(ARRAY_SIZE)-1:0] sum [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];

reg signed [WIDTH-1:0] left [ARRAY_SIZE-1:0];
reg signed [WIDTH-1:0] up [ARRAY_SIZE-1:0];

reg [$clog2(3*ARRAY_SIZE):0] flag;

genvar i, j, k, l;

generate
    for(i = 0; i < ARRAY_SIZE; i = i + 1) begin
        for(j = 0; j < 2 * ARRAY_SIZE - 1; j = j + 1) begin
            always @(posedge clk) begin
                if(rst) begin
                    result <= 0;
                    row[i][j] <= {WIDTH{1'b0}};
                    col[i][j] <= {WIDTH{1'b0}};
                end
                else begin
                    if((j < i) || (j - i >= ARRAY_SIZE)) begin
                        row[i][j] <= {WIDTH{1'b0}};
                        col[i][j] <= {WIDTH{1'b0}};
                    end
                    else begin
                        row[i][j] <= in1[((i * ARRAY_SIZE + j + 1 - i) * WIDTH - 1)-:WIDTH];
                        col[i][j] <= in2[((i + 1 + ARRAY_SIZE * (j - i)) * WIDTH - 1)-:WIDTH];
                    end
                end
            end
        end
    end
endgenerate

always @(posedge clk) begin
    if(rst) begin
        flag <= 0;
    end
    else if(en) begin
        if(flag < 3 * ARRAY_SIZE - 1) begin
            flag <= flag + 1;
        end
        else begin
            flag <= flag;
        end
    end
end

generate
    for(i = 0; i < ARRAY_SIZE; i = i + 1) begin
        always @(posedge clk) begin
            if(flag < 2 * ARRAY_SIZE - 1) begin
                left[i] <= row[i][flag];
                up[i]   <= col[i][flag];
            end
            else begin
                left[i] <= 0;
                up[i]   <= 0;
            end
        end
    end

    for(k = ARRAY_SIZE - 1; k >= 0; k = k - 1) begin
        for(l = ARRAY_SIZE - 1; l >= 0; l = l - 1) begin
            always @(posedge clk) begin
                if(flag == 3 * ARRAY_SIZE - 1) begin
                    result[((2 * WIDTH + $clog2(ARRAY_SIZE)) * (ARRAY_SIZE * k + l + 1) - 1)-:(2 * WIDTH + $clog2(ARRAY_SIZE))]  <= sum[k][l];
                end
            end
        end
    end
endgenerate

genvar r, c;
generate
    for(r = 0; r < ARRAY_SIZE; r = r + 1) begin : ROW_LOOP
        for(c = 0; c < ARRAY_SIZE; c = c + 1) begin : COL_LOOP
            wire signed [WIDTH-1:0] w_left;
            wire signed [WIDTH-1:0] w_up;

            assign w_left   = (c == 0) ? left[r] : right[r][c-1];
            assign w_up     = (r == 0) ? up[c] : down[r-1][c];
            
            Processing_Element #(
                .WIDTH      (WIDTH),
                .ARRAY_SIZE (ARRAY_SIZE)
            ) u_Processing_Element (
                .clk    (clk),
                .rst    (rst),
                .left   (w_left),
                .up     (w_up),
                .down   (down[r][c]),
                .right  (right[r][c]),
                .sum_out(sum[r][c])
            );
        end
    end
endgenerate

endmodule