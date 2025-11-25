module Processing_Element
#(
    parameter WIDTH = 8,
    parameter ARRAY_SIZE = 4
)
(
    input                                                   clk,
    input                                                   rst,
    input       signed  [WIDTH-1:0]                         left,
    input       signed  [WIDTH-1:0]                         up,
    output  reg signed  [WIDTH-1:0]                         down,
    output  reg signed  [WIDTH-1:0]                         right,
    output  reg signed  [2*WIDTH+$clog2(ARRAY_SIZE)-1:0]    sum_out
);

wire signed [2*WIDTH:0] mult_out;

always @(posedge clk) begin
    if(rst) begin
        right   <= {WIDTH{1'sd0}};
        down    <= {WIDTH{1'sd0}};
        sum_out <= {(2*WIDTH+$clog2(ARRAY_SIZE)){1'sd0}};
    end
    else begin
        down    <= up;
        right   <= left;
        sum_out <= sum_out + mult_out;
    end
end

assign mult_out = left * up;

endmodule