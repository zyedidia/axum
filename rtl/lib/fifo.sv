module fifo
    #(
        parameter DATA_WIDTH=8, // number of bits in a word
        parameter ADDR_WIDTH=4  // number of address bits
    )
    (
        input  logic clk_i,
        input  logic rst_ni,
        input  logic rd_i,
        input  logic wr_i,
        input  logic [DATA_WIDTH-1:0] w_data_i,
        output logic empty_o,
        output logic full_o,
        output logic [DATA_WIDTH-1:0] r_data_o
    );

    logic [ADDR_WIDTH-1:0] w_addr, r_addr;
    logic wr_en, full_tmp;

    // write enabled only when FIFO is not full
    assign wr_en = wr_i & ~full_tmp;
    assign full_o = full_tmp;

    fifo_ctrl #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_fifo_ctrl (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .rd_i     (rd_i),
        .wr_i     (wr_i),
        .empty_o  (empty_o),
        .full_o   (full_tmp),
        .w_addr_o (w_addr),
        .r_addr_o (r_addr)
    );

    fifo_reg_file #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_fifo_reg_file (
        .clk_i    (clk_i),
        .wr_en_i  (wr_en),
        .w_addr_i (w_addr),
        .r_addr_i (r_addr),
        .w_data_i (w_data_i),
        .r_data_o (r_data_o)
    );
endmodule
