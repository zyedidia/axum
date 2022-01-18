module axum_uart
    #(
        parameter FIFO_DEPTH_BIT = 4 // # addr bits of FIFO
    )
    (
        input logic clk_i,
        input logic rst_ni,

        input  rx_i,
        output tx_o,

        // Bus interface
        input  logic        uart_req_i,
        input  logic [31:0] uart_addr_i,
        input  logic        uart_we_i,
        input  logic [3:0]  uart_be_i,
        input  logic [31:0] uart_wdata_i,
        output logic        uart_rvalid_o,
        output logic [31:0] uart_rdata_o,
        output logic        uart_err_o,
        output logic        uart_intr_o
    );

    localparam int unsigned ADDR_OFFSET = 10;
    // Register map
    localparam bit [9:0] TX_DATA = 0;
    localparam bit [9:0] RX_DATA = 4;
    localparam bit [9:0] DVSR    = 8;
    localparam bit [9:0] CLEAR   = 12;

    logic        uart_we;
    logic [31:0] rdata_q, rdata_d;
    logic        error_q, error_d;
    logic        rvalid_q;
    logic        tx_data_we, dvsr_we, clear_we;
    logic [10:0] dvsr_q, dvsr_d;
    logic        tx_full, rx_empty;
    logic        ctrl_reg;
    logic [7:0]  r_data;

    assign uart_we = uart_req_i & uart_we_i;

    assign tx_data_we = uart_we & (uart_addr_i[ADDR_OFFSET-1:0] == TX_DATA);
    assign dvsr_we = uart_we & (uart_addr_i[ADDR_OFFSET-1:0] == DVSR);
    assign clear_we = uart_we & (uart_addr_i[ADDR_OFFSET-1:0] == CLEAR);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            dvsr_q <= 32'b0;
        end else begin
            if (dvsr_we) dvsr_q <= uart_wdata_i;
        end
    end

    always_comb begin
        rdata_d = 32'b0;
        error_d = 1'b0;
        unique case (uart_addr_i[ADDR_OFFSET-1:0])
            RX_DATA: rdata_d = {22'h000000, tx_full, rx_empty, r_data};
            DVSR:    rdata_d = dvsr_q;
            // write-only registers
            TX_DATA: begin end
            CLEAR:   begin end
            default begin
                rdata_d = 32'b0;
                error_d = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (uart_req_i) begin
            rdata_q <= rdata_d;
            error_q <= error_d;
        end
    end

    assign uart_rdata_o = rdata_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            rvalid_q <= 1'b0;
        end else begin
            rvalid_q <= uart_req_i;
        end
    end

    assign uart_rvalid_o = rvalid_q;
    assign uart_err_o = error_q;
    assign uart_intr_o = 1'b0;

    uart #(
        .DBIT    (8),
        .SB_TICK (16),
        .FIFO_W  (FIFO_DEPTH_BIT)
    ) u_uart (
        .clk_i,
        .rst_ni,
        .rd_uart_i  (clear_we),
        .wr_uart_i  (tx_data_we),
        .rx_i       (rx_i),
        .w_data_i   (uart_wdata_i),
        .dvsr_i     (dvsr_q),
        .tx_full_o  (tx_full),
        .rx_empty_o (rx_empty),
        .tx_o       (tx_o),
        .r_data_o   (r_data)
    );
endmodule
