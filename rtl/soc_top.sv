module soc_top
    (
        input logic clk,
        input logic rst_n,

        // input logic usr_btn_i,

        inout logic gpio_0,
        inout logic gpio_1,
        inout logic gpio_5,
        inout logic gpio_6,
        inout logic gpio_9,
        inout logic gpio_10,
        inout logic gpio_11,
        inout logic gpio_12,
        inout logic gpio_13,
        inout logic gpio_a0,
        inout logic gpio_a1,
        inout logic gpio_a2,
        inout logic gpio_a3,

        output logic rgb_led0_r,
        output logic rgb_led0_g,
        output logic rgb_led0_b
    );

    parameter int          MEM_SIZE     = 8 * 1024; // 8 kB
    parameter logic [31:0] MEM_START    = 32'h00000000;
    parameter logic [31:0] MEM_MASK     = MEM_SIZE-1;
    parameter              SRAMInitFile = "";
    parameter bit          ECP5PLL      = 1'b0;

    logic clk_sys, rst_sys_n;

    if (ECP5PLL) begin
        logic locked;

        clkgen ecp5clk (
            .clk, .clk_sys,
            .locked
        );

        logic [3:0] rst_cnt;
        logic       rst;

        // ensure reset release is synchronous with the clock
        always @(posedge clk or negedge locked)
            if (!locked)
                rst_cnt <= 4'h8;
            else if (rst_cnt[3])
                rst_cnt <= rst_cnt + 1;

        assign rst = rst_cnt[3];
        assign rst_sys_n = ~rst;
    end else begin
        assign clk_sys = clk;
        assign rst_sys_n = rst_n;
    end

    typedef enum logic {
        CoreD
    } bus_host_e;

    typedef enum logic[1:0] {
        Ram,
        Gpio,
        Timer
    } bus_device_e;

    localparam int NrDevices = 3;
    localparam int NrHosts = 1;

    // interrupts
    logic timer_irq;

    // host and device signals
    logic           host_req    [NrHosts];
    logic           host_gnt    [NrHosts];
    logic [31:0]    host_addr   [NrHosts];
    logic           host_we     [NrHosts];
    logic [ 3:0]    host_be     [NrHosts];
    logic [31:0]    host_wdata  [NrHosts];
    logic           host_rvalid [NrHosts];
    logic [31:0]    host_rdata  [NrHosts];
    logic           host_err    [NrHosts];

    // devices
    logic           device_req    [NrDevices];
    logic [31:0]    device_addr   [NrDevices];
    logic           device_we     [NrDevices];
    logic [ 3:0]    device_be     [NrDevices];
    logic [31:0]    device_wdata  [NrDevices];
    logic           device_rvalid [NrDevices];
    logic [31:0]    device_rdata  [NrDevices];
    logic           device_err    [NrDevices];

    // Device address mapping
    logic [31:0] cfg_device_addr_base [NrDevices];
    logic [31:0] cfg_device_addr_mask [NrDevices];
    assign cfg_device_addr_base[Ram] = 32'h100000;
    assign cfg_device_addr_mask[Ram] = ~MEM_MASK; // 8 kB
    assign cfg_device_addr_base[Gpio] = 32'h20000;
    assign cfg_device_addr_mask[Gpio] = ~32'h3FF; // 1 kB
    assign cfg_device_addr_base[Timer] = 32'h30000;
    assign cfg_device_addr_mask[Timer] = ~32'h3FF; // 1 kB

    // Instruction fetch signals
    logic instr_req;
    logic instr_gnt;
    logic instr_rvalid;
    logic [31:0] instr_addr;
    logic [31:0] instr_rdata;
    logic instr_err;

    assign instr_gnt = instr_req;
    assign instr_err = '0;

    // Tie-off unused error signals
    assign device_err[Ram] = 1'b0;

    bus #(
        .NrDevices    ( NrDevices ),
        .NrHosts      ( NrHosts   ),
        .DataWidth    ( 32        ),
        .AddressWidth ( 32        )
    ) u_bus (
        .clk_i               (clk_sys),
        .rst_ni              (rst_sys_n),

        .host_req_i          (host_req     ),
        .host_gnt_o          (host_gnt     ),
        .host_addr_i         (host_addr    ),
        .host_we_i           (host_we      ),
        .host_be_i           (host_be      ),
        .host_wdata_i        (host_wdata   ),
        .host_rvalid_o       (host_rvalid  ),
        .host_rdata_o        (host_rdata   ),
        .host_err_o          (host_err     ),

        .device_req_o        (device_req   ),
        .device_addr_o       (device_addr  ),
        .device_we_o         (device_we    ),
        .device_be_o         (device_be    ),
        .device_wdata_o      (device_wdata ),
        .device_rvalid_i     (device_rvalid),
        .device_rdata_i      (device_rdata ),
        .device_err_i        (device_err   ),

        .cfg_device_addr_base,
        .cfg_device_addr_mask
    );

    ibex_top #(
        .RegFile(ibex_pkg::RegFileFPGA),
        .DmHaltAddr      ( 32'h00100000    ),
        .DmExceptionAddr ( 32'h00100000    )
    ) u_top (
        .clk_i                 (clk_sys),
        .rst_ni                (rst_sys_n),

        .test_en_i             ('b0),
        .scan_rst_ni           (1'b1),
        .ram_cfg_i             ('b0),

        .hart_id_i             (32'b0),
        // First instruction executed is at 0x100000 + 0x80
        .boot_addr_i           (32'h00100000),

        .instr_req_o           (instr_req),
        .instr_gnt_i           (instr_gnt),
        .instr_rvalid_i        (instr_rvalid),
        .instr_addr_o          (instr_addr),
        .instr_rdata_i         (instr_rdata),
        .instr_rdata_intg_i    ('0),
        .instr_err_i           (instr_err),

        .data_req_o            (host_req[CoreD]),
        .data_gnt_i            (host_gnt[CoreD]),
        .data_rvalid_i         (host_rvalid[CoreD]),
        .data_we_o             (host_we[CoreD]),
        .data_be_o             (host_be[CoreD]),
        .data_addr_o           (host_addr[CoreD]),
        .data_wdata_o          (host_wdata[CoreD]),
        .data_wdata_intg_o     (),
        .data_rdata_i          (host_rdata[CoreD]),
        .data_rdata_intg_i     ('0),
        .data_err_i            (host_err[CoreD]),

        .irq_software_i        (1'b0),
        .irq_timer_i           (timer_irq),
        .irq_external_i        (1'b0),
        .irq_fast_i            (15'b0),
        .irq_nm_i              (1'b0),

        .debug_req_i           ('b0),
        .crash_dump_o          (),

        .fetch_enable_i        ('b1),
        .alert_minor_o         (),
        .alert_major_o         (),
        .core_sleep_o          ()
    );

    // SRAM block for instruction and data storage
    ram_2p #(
        .Depth(MEM_SIZE / 4),
        .MemInitFile(SRAMInitFile)
    ) u_ram (
        .clk_i       (clk_sys),
        .rst_ni      (rst_sys_n),

        .a_req_i     (device_req[Ram]),
        .a_we_i      (device_we[Ram]),
        .a_be_i      (device_be[Ram]),
        .a_addr_i    (device_addr[Ram]),
        .a_wdata_i   (device_wdata[Ram]),
        .a_rvalid_o  (device_rvalid[Ram]),
        .a_rdata_o   (device_rdata[Ram]),

        .b_req_i     (instr_req),
        .b_we_i      (1'b0),
        .b_be_i      (4'b0),
        .b_addr_i    (instr_addr),
        .b_wdata_i   (32'b0),
        .b_rvalid_o  (instr_rvalid),
        .b_rdata_o   (instr_rdata)
    );

    timer #(
        .DataWidth    (32),
        .AddressWidth (32)
    ) u_timer (
        .clk_i          (clk_sys),
        .rst_ni         (rst_sys_n),

        .timer_req_i    (device_req[Timer]),
        .timer_we_i     (device_we[Timer]),
        .timer_be_i     (device_be[Timer]),
        .timer_addr_i   (device_addr[Timer]),
        .timer_wdata_i  (device_wdata[Timer]),
        .timer_rvalid_o (device_rvalid[Timer]),
        .timer_rdata_o  (device_rdata[Timer]),
        .timer_err_o    (device_err[Timer]),
        .timer_intr_o   (timer_irq)
    );


    logic [31:0] gpio_inout;

    // assign gpio_0 = gpio_inout[0];
    // assign gpio_1 = gpio_inout[1];
    // assign gpio_5 = gpio_inout[2];
    // assign gpio_6 = gpio_inout[3];
    // assign gpio_9 = gpio_inout[4];
    // assign gpio_10 = gpio_inout[5];
    // assign gpio_11 = gpio_inout[6];
    // assign gpio_12 = gpio_inout[7];
    // assign gpio_13 = gpio_inout[8];
    // assign gpio_a0 = gpio_inout[9];
    // assign gpio_a1 = gpio_inout[10];
    // assign gpio_a2 = gpio_inout[11];
    // assign gpio_a3 = gpio_inout[12];
    // assign gpio_inout[13] = usr_btn_i;
    assign rgb_led0_r = ~gpio_inout[14];
    assign rgb_led0_g = ~gpio_inout[15];
    assign rgb_led0_b = ~gpio_inout[16];

    gpio #(
        .DataWidth    (32),
        .AddressWidth (32)
    ) u_gpio (
        .clk_i         (clk_sys),
        .rst_ni        (rst_sys_n),

        .gpio_inout    (gpio_inout),

        .gpio_req_i    (device_req[Gpio]),
        .gpio_we_i     (device_we[Gpio]),
        .gpio_be_i     (device_be[Gpio]),
        .gpio_addr_i   (device_addr[Gpio]),
        .gpio_wdata_i  (device_wdata[Gpio]),
        .gpio_rvalid_o (device_rvalid[Gpio]),
        .gpio_rdata_o  (device_rdata[Gpio]),
        .gpio_err_o    (device_err[Gpio]),
        .gpio_intr_o   ()
    );
endmodule
