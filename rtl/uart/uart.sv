module uart
    #(
        parameter DBIT = 8,     // data bits
        parameter SB_TICK = 16, // ticks for 1 stop bit
        parameter FIFO_W = 2    // addr bits of FIFO
    )
    (
        input logic clk_i,
        input logic rst_ni,
        input logic rd_uart_i,
        input logic wr_uart_i,
        input logic rx_i,
        input logic [7:0] w_data_i,
        input logic [10:0] dvsr_i,
        output logic tx_full_o,
        output logic rx_empty_o,
        output logic tx_o,
        output logic [7:0] r_data_o
    );

    logic tick, rx_done_tick, tx_done_tick;
    logic tx_empty, tx_fifo_not_empty;
    logic [7:0] tx_fifo_out, rx_data_out;

    baud_gen u_baud_gen (
        .clk_i,
        .rst_ni,
        .dvsr_i,
        .tick_o (tick)
    );

    uart_rx #(
        .DBIT_MAX    (DBIT-1),
        .SB_TICK_MAX (SB_TICK-1)
    ) u_uart_rx (
        .clk          (clk_i),
        .reset        (~rst_ni),
        .rx           (rx_i),
        .tick         (tick),
        .rx_done_tick (rx_done_tick),
        .dout         (rx_data_out)
    );

    uart_tx #(
        .DBIT_MAX    (DBIT-1),
        .SB_TICK_MAX (SB_TICK-1)
    ) u_uart_tx (
        .clk          (clk_i),
        .reset        (~rst_ni),
        .tx_start     (tx_fifo_not_empty),
        .tick         (tick),
        .din          (tx_fifo_out),
        .tx_done_tick (tx_done_tick),
        .tx           (tx_o)
    );

    fifo #(
        .DATA_WIDTH (DBIT),
        .ADDR_WIDTH (FIFO_W)
    ) u_fifo_rx (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .rd_i     (rd_uart_i),
        .wr_i     (rx_done_tick),
        .w_data_i (rx_data_out),
        .empty_o  (rx_empty_o),
        .full_o   (),
        .r_data_o (r_data_o)
    );

    fifo #(
        .DATA_WIDTH (DBIT),
        .ADDR_WIDTH (FIFO_W)
    ) u_fifo_tx (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .rd_i     (tx_done_tick),
        .wr_i     (wr_uart_i),
        .w_data_i (w_data_i),
        .empty_o  (tx_empty),
        .full_o   (tx_full_o),
        .r_data_o (tx_fifo_out)
    );

    assign tx_fifo_not_empty = ~tx_empty;
endmodule
