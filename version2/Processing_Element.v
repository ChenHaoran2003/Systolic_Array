module Processing_Element(
    input                       clk,
    input                       rst,
    input       signed  [7:0]   left,
    input       signed  [7:0]   up,
    output  reg signed  [7:0]   down,
    output  reg signed  [7:0]   right,
    output  reg signed  [17:0]   sum_out
);

wire signed [14:0] mult_out;

always @(posedge clk) begin
    if(rst) begin
        right   <= 8'sd0;
        down    <= 8'sd0;
        sum_out <= 18'sd0;
    end
    else begin
        down    <= up;
        right   <= left;
        sum_out <= sum_out + mult_out;
    end
end

assign mult_out = left * up;

endmodule