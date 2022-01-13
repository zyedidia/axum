module soc_top (
    input               clk,
    input               rst_n,
    output              rgb_led0_r
);

  parameter int          MEM_SIZE     = 8 * 1024; // 8 kB
  parameter logic [31:0] MEM_START    = 32'h00000000;
  parameter logic [31:0] MEM_MASK     = MEM_SIZE-1;
  parameter              SRAMInitFile = "";

  logic clk_sys, rst_sys_n;

  // assign clk_sys = clk;
  assign rst_sys_n = rst_n;

  // Instruction connection to SRAM
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;

  // Data connection to SRAM
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic  [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  ibex_top #(
     .RegFile(ibex_pkg::RegFileFPGA),
     .DmHaltAddr(32'h00000000),
     .DmExceptionAddr(32'h00000000)
  ) u_top (
     .clk_i                 (clk_sys),
     .rst_ni                (rst_sys_n),

     .test_en_i             ('b0),
     .scan_rst_ni           (1'b1),
     .ram_cfg_i             ('b0),

     .hart_id_i             (32'b0),
     // First instruction executed is at 0x0 + 0x80
     .boot_addr_i           (32'h00000000),

     .instr_req_o           (instr_req),
     .instr_gnt_i           (instr_gnt),
     .instr_rvalid_i        (instr_rvalid),
     .instr_addr_o          (instr_addr),
     .instr_rdata_i         (instr_rdata),
     .instr_rdata_intg_i    ('0),
     .instr_err_i           ('b0),

     .data_req_o            (data_req),
     .data_gnt_i            (data_gnt),
     .data_rvalid_i         (data_rvalid),
     .data_we_o             (data_we),
     .data_be_o             (data_be),
     .data_addr_o           (data_addr),
     .data_wdata_o          (data_wdata),
     .data_wdata_intg_o     (),
     .data_rdata_i          (data_rdata),
     .data_rdata_intg_i     ('0),
     .data_err_i            ('b0),

     .irq_software_i        (1'b0),
     .irq_timer_i           (1'b0),
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
    .clk_i (clk_sys),
    .rst_ni(rst_sys_n),

    .a_req_i   (data_req),
    .a_we_i    (data_we),
    .a_be_i    (data_be),
    .a_addr_i  (data_addr),
    .a_wdata_i (data_wdata),
    .a_rvalid_o(data_rvalid),
    .a_rdata_o (data_rdata),

    .b_req_i   (instr_req),
    .b_we_i    (1'b0),
    .b_be_i    (4'b0),
    .b_addr_i  (instr_addr),
    .b_wdata_i (32'b0),
    .b_rvalid_o(instr_rvalid),
    .b_rdata_o (instr_rdata)
  );


  // SRAM to Ibex
  assign instr_gnt = instr_req;
  assign data_gnt = data_req;

  assign rgb_led0_r = data_wdata[0];

  assign clk_sys = clk;
  // clkgen ecp5clk (
  //     .clk, .clk_sys,
  // );
endmodule
