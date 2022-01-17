module fifo_reg_file
    #(
        parameter DATA_WIDTH = 8, // number of bits
        parameter ADDR_WIDTH = 2  // number of address bits
    )
    (
        input  logic clk_i,
        input  logic wr_en_i,
        input  logic [ADDR_WIDTH-1:0] w_addr_i,
        input  logic [ADDR_WIDTH-1:0] r_addr_i,
        input  logic [DATA_WIDTH-1:0] w_data_i,
        output logic [DATA_WIDTH-1:0] r_data_o
    );

    // signal declaration
    logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

    // write operation
    always_ff @(posedge clk_i)
        if (wr_en_i)
            array_reg[w_addr_i] <= w_data_i;
    // read operation
    assign r_data_o = array_reg[r_addr_i];
endmodule

