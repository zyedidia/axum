module baud_gen
    (
        input logic clk_i,
        input logic rst_ni,
        input logic [10:0] dvsr_i,
        output logic tick_o
    );

    logic [10:0] count_q, count_d;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            count_q <= 10'b0;
        end else begin
            count_q <= count_d;
        end
    end

    assign count_d = (count_q == dvsr_i) ? 10'b0 : count_q + 1;
    assign tick_o = count_q == 10'd1;
endmodule
