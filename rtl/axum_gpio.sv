module axum_gpio
    #(
        parameter int unsigned DataWidth    = 32,
        parameter int unsigned AddressWidth = 32
    )
    (
        input logic clk_i,
        input logic rst_ni,

        inout tri [31:0] gpio_inout,

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

    localparam int unsigned ADDR_OFFSET = 10; // 1kB
    // Register map
    localparam bit [9:0] INPUT_VAL  = 0;
    localparam bit [9:0] INPUT_EN   = 4;
    localparam bit [9:0] OUTPUT_EN  = 8;
    localparam bit [9:0] OUTPUT_VAL = 12;
    localparam bit [9:0] IOF_EN     = 16;
    localparam bit [9:0] IOF_SEL    = 20;
    localparam bit [9:0] OUT_XOR    = 24;

    logic        gpio_we;
    logic [31:0] rdata_q, rdata_d;
    logic        error_q, error_d;
    logic        rvalid_q;
    logic        input_en_we, output_en_we, output_val_we;
    logic        iof_en_we, iof_sel_we, out_xor_we;
    logic [31:0] input_en_q, input_en_d;
    logic [31:0] output_en_q, output_en_d;
    logic [31:0] output_val_q, output_val_d;
    logic [31:0] iof_en_q, iof_en_d;
    logic [31:0] iof_sel_q, iof_sel_d;
    logic [31:0] out_xor_q, out_xor_d;

    assign gpio_we = gpio_req_i & gpio_we_i;

    assign input_en_we   = gpio_we & (gpio_addr_i[ADDR_OFFSET-1:0] == INPUT_EN);
    assign output_en_we  = gpio_we & (gpio_addr_i[ADDR_OFFSET-1:0] == OUTPUT_EN);
    assign output_val_we = gpio_we & (gpio_addr_i[ADDR_OFFSET-1:0] == OUTPUT_VAL);
    assign iof_en_we     = gpio_we & (gpio_addr_i[ADDR_OFFSET-1:0] == IOF_EN);
    assign iof_sel_we    = gpio_we & (gpio_addr_i[ADDR_OFFSET-1:0] == IOF_SEL);
    assign out_xor_we    = gpio_we & (gpio_addr_i[ADDR_OFFSET-1:0] == OUT_XOR);

    assign input_en_d   = input_en_we ? gpio_wdata_i : input_en_q;
    assign output_en_d  = output_en_we ? gpio_wdata_i : output_en_q;
    assign output_val_d = output_val_we ? gpio_wdata_i : output_val_q;
    assign iof_en_d     = iof_en_we ? gpio_wdata_i : iof_en_q;
    assign iof_sel_d    = iof_sel_we ? gpio_wdata_i : iof_sel_q;
    assign out_xor_d    = out_xor_we ? gpio_wdata_i : out_xor_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            input_en_q <= 32'b0;
            output_en_q <= 32'b0;
            output_val_q <= 32'b0;
            iof_en_q <= 32'b0;
            iof_sel_q <= 32'b0;
            out_xor_q <= 32'b0;
        end else begin
            if (input_en_we)   input_en_q   <= input_en_d;
            if (output_en_we)  output_en_q  <= output_en_d;
            if (output_val_we) output_val_q <= output_val_d;
            if (iof_en_we)     iof_en_q     <= iof_en_d;
            if (iof_sel_we)    iof_sel_q    <= iof_sel_d;
            if (out_xor_we)    out_xor_q    <= out_xor_d;
        end
    end

    always_comb begin
        rdata_d = 'b0;
        error_d = 1'b0;
        unique case (gpio_addr_i[ADDR_OFFSET-1:0])
            INPUT_VAL:  begin 
                for (int i = 0; i < 32; i++) begin
                    rdata_d[i] = input_en_q[i] ? gpio_inout[i] : 1'b0;
                end
            end
            INPUT_EN:   rdata_d = input_en_q;
            OUTPUT_EN:  rdata_d = output_en_q;
            OUTPUT_VAL: rdata_d = output_val_q;
            IOF_EN:     rdata_d = iof_en_q;
            IOF_SEL:    rdata_d = iof_sel_q;
            OUT_XOR:    rdata_d = out_xor_q;
            default: begin
                rdata_d = 'b0;
                error_d = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (gpio_req_i) begin
            rdata_q <= rdata_d;
            error_q <= error_d;
        end
    end

    assign gpio_rdata_o = rdata_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            rvalid_q <= 1'b0;
        end else begin
            rvalid_q <= gpio_req_i;
        end
    end

    assign gpio_rvalid_o = rvalid_q;
    assign gpio_err_o  = error_q;

    assign gpio_intr_o = 1'b0;

    generate
        genvar i;
        for (i = 0; i < 31; i++) begin
            assign gpio_inout[i] = output_en_q[i] ? output_val_q[i] ^ out_xor_q[i] : 1'bz;
        end
    endgenerate
endmodule
