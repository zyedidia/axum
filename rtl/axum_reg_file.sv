module axum_reg_file import ibex_pkg::*;
    #(
        parameter bit RV32E = 1'b0,
        parameter regfile_e RegFile = RegFileFF,
        parameter RegFileDataWidth = 32,
        parameter DataWidth = 32,
        parameter AddressWidth = 32
    )
    (
        input logic clk_i,
        input logic rst_ni,

        // Bus interface
        input  logic                    rf_map_req_i,
        input  logic [AddressWidth-1:0] rf_map_addr_i,
        input  logic                    rf_map_we_i,
        input  logic [ DataWidth/8-1:0] rf_map_be_i,
        input  logic [   DataWidth-1:0] rf_map_wdata_i,
        output logic                    rf_map_rvalid_o,
        output logic [   DataWidth-1:0] rf_map_rdata_o,
        output logic                    rf_map_err_o,
        output logic                    rf_map_intr_o,

        // Register file interface
        input logic [4:0]                    rf_raddr_a_i,
        input logic [4:0]                    rf_raddr_b_i,
        input logic [4:0]                    rf_waddr_wb_i,
        input logic                          rf_we_wb_i,
        input logic [RegFileDataWidth-1:0]   rf_wdata_wb_ecc_i,
        output  logic [RegFileDataWidth-1:0] rf_rdata_a_ecc_o,
        output  logic [RegFileDataWidth-1:0] rf_rdata_b_ecc_o,
        input reg_ctx_e                      rf_ctx_sel_i
    );

    localparam int unsigned ADDR_OFFSET = 10; // 1kB

    logic [31:0] rdata_q, rdata_d;
    logic        error_q, error_d;
    logic        rvalid_q;

    logic                        rf_we_wb_w [NR_REG_CTX];
    logic [RegFileDataWidth-1:0] rf_rdata_a_ecc_w [NR_REG_CTX];
    logic [RegFileDataWidth-1:0] rf_rdata_b_ecc_w [NR_REG_CTX];
    logic [RegFileDataWidth-1:0] rf_rdata_c_ecc_w [NR_REG_CTX];

    logic [4:0]                  rf_waddr_w [NR_REG_CTX];
    logic [RegFileDataWidth-1:0] rf_wdata_w [NR_REG_CTX];

    logic rf_map_we = rf_map_req_i & rf_map_we_i;

    assign rf_rdata_a_ecc_o = rf_rdata_a_ecc_w[rf_ctx_sel_i];
    assign rf_rdata_b_ecc_o = rf_rdata_b_ecc_w[rf_ctx_sel_i];
    assign rdata_d = rf_map_addr_i[8:7] != rf_ctx_sel_i ? rf_rdata_c_ecc_w[rf_map_addr_i[8:7]] : 32'b0;

    for (genvar r = 0; r < NR_REG_CTX; r++) begin : gen_regfile_ctxts
        assign rf_we_wb_w[r] = rf_ctx_sel_i == r ? rf_we_wb_i : rf_map_we;
        assign rf_waddr_w[r] = rf_ctx_sel_i == r ? rf_waddr_wb_i : rf_map_addr_i[6:2];
        assign rf_wdata_w[r] = rf_ctx_sel_i == r ? rf_wdata_wb_ecc_i : rf_map_wdata_i;

        ibex_register_file_fpga #(
            .RV32E            (RV32E),
            .DataWidth        (RegFileDataWidth),
            .WordZeroVal      (RegFileDataWidth'(prim_secded_pkg::SecdedInv3932ZeroWord))
        ) register_file_i (
            .clk_i (clk_i),
            .rst_ni(rst_ni),

            .dummy_instr_id_i(),
            .test_en_i(1'b0),

            .raddr_a_i(rf_raddr_a_i),
            .rdata_a_o(rf_rdata_a_ecc_w[r]),
            .raddr_b_i(rf_raddr_b_i),
            .rdata_b_o(rf_rdata_b_ecc_w[r]),
            .raddr_c_i(rf_map_addr_i[6:2]),
            .rdata_c_o(rf_rdata_c_ecc_w[r]),
            .waddr_a_i(rf_waddr_w[r]),
            .wdata_a_i(rf_wdata_w[r]),
            .we_a_i   (rf_we_wb_w[r])
        );
    end

    assign error_d = 1'b0;

    always_ff @(posedge clk_i) begin
        if (rf_map_req_i) begin
            rdata_q <= rdata_d;
            error_q <= error_d;
        end
    end

    assign rf_map_rdata_o = rdata_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            rvalid_q <= 1'b0;
        end else begin
            rvalid_q <= rf_map_req_i;
        end
    end

    assign rf_map_rvalid_o = rvalid_q;
    assign rf_map_err_o = error_q;
    assign rf_map_intr_o = 1'b0;

endmodule
