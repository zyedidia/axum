module gpio
    #(
        parameter int unsigned DataWidth    = 32,
        parameter int unsigned AddressWidth = 32
    )
    (
        input logic clk_i,
        input logic rst_ni,

        inout logic [31:0] gpio_inout,

        // Bus interface
        input  logic                    gpio_req_i,
        input  logic [AddressWidth-1:0] gpio_addr_i,
        input  logic                    gpio_we_i,
        input  logic [ DataWidth/8-1:0] gpio_be_i,
        input  logic [   DataWidth-1:0] gpio_wdata_i,
        output logic                    gpio_rvalid_o,
        output logic [   DataWidth-1:0] gpio_rdata_o,
        output logic                    gpio_err_o,
        output logic                    gpio_intr_o
    );

    logic [31:0] gpo_q, gpo_d;
    logic [31:0] gpio_fsel_q, gpio_fsel_d;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            gpo_q <= 32'b0;
            gpio_fsel_q <= 32'b0;
        end else begin
            gpo_q <= gpo_d;
            gpio_fsel_q <= gpio_fsel_d;
        end
    end

    always_comb begin
        gpo_d = gpo_q;
        gpio_fsel_d = gpio_fsel_q;
    end

    generate
        genvar i;
        for (i = 0; i < 32; i++) begin
            assign gpio_inout[i] = gpio_fsel_q[i] ? 1'b0 : gpo_q[i];
        end
    endgenerate
endmodule
