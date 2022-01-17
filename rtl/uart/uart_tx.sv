module uart_tx
    #(
        parameter DBIT_MAX = 7,
        parameter SB_TICK_MAX = 15
    )
    (
        input logic clk, reset,
        input logic tx_start, tick,
        input logic [7:0] din,
        output logic tx_done_tick,
        output logic tx
    );

    typedef enum {idle, start, data, stop} state_t;
    state_t state_reg = idle;
    state_t state_next;

    logic [3:0] tick_reg, tick_next;
    logic [2:0] n_reg, n_next;
    logic [7:0] b_reg, b_next;
    logic tx_reg, tx_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= idle;
            tick_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1;
        end else begin
            state_reg <= state_next;
            tick_reg <= tick_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end

    always_comb begin
        state_next = state_reg;
        tx_done_tick = 1'b0;
        tick_next = tick_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;
        
        case (state_reg)
            idle: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    state_next = start;
                    tick_next = 0;
                    b_next = din;
                end
            end
            start: begin
                tx_next = 1'b0;
                if (tick) begin
                    if (tick_reg == 15) begin
                        state_next = data;
                        tick_next = 0;
                        n_next = 0;
                    end else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
            data: begin
                tx_next = b_reg[0];
                if (tick) begin
                    if (tick_reg == 15) begin
                        tick_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg == DBIT_MAX)
                            state_next = stop;
                        else
                            n_next = n_reg + 1;
                    end else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
            stop: begin
                tx_next = 1'b1;
                if (tick) begin
                    if (tick_reg == SB_TICK_MAX) begin
                        state_next = idle;
                        tx_done_tick = 1'b1;
                    end else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
        endcase
    end

    assign tx = tx_reg;
endmodule
