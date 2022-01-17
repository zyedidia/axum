module uart_rx
    #(
        parameter DBIT_MAX = 7,
        parameter SB_TICK_MAX = 15
    )
    (
        input logic clk, reset,
        input logic rx,            // serial data
        input logic tick,          // baud rate oversampled tick
        output logic rx_done_tick, // pulse one tick when done
        output logic [7:0] dout    // output data
    );

    typedef enum {idle, start, data, stop} state_t;
    state_t state_reg = idle;
    state_t state_next;

    logic [3:0] tick_reg, tick_next;
    logic [2:0] n_reg, n_next;
    logic [7:0] b_reg, b_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= idle;
            tick_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end else begin
            state_reg <= state_next;
            tick_reg <= tick_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end

    always_comb begin
        state_next = state_reg;
        rx_done_tick = 1'b0;
        tick_next = tick_reg;
        n_next = n_reg;
        b_next = b_reg;

        case (state_reg)
            idle: begin
                if (~rx) begin
                    state_next = start;
                    tick_next = 0;
                end
            end
            start: begin
                if (tick) begin
                    if (tick_reg == 7) begin
                        state_next = data;
                        tick_next = 0;
                        n_next = 0;
                    end else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
            data: begin
                if (tick) begin
                    if (tick_reg == 15) begin
                        tick_next = 0;
                        b_next = {rx, b_reg[7:1]};
                        if (n_reg == DBIT_MAX) begin
                            state_next = stop;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
            stop: begin
                if (tick) begin
                    if (tick_reg == SB_TICK_MAX) begin
                        state_next = idle;
                        rx_done_tick = 1'b1;
                    end else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
        endcase
    end

    assign dout = b_reg;
endmodule
