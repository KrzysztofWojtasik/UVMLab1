module top;

    logic clk;
    logic rstn;

    tb_top u_tb (
        .clk  (clk),
        .rstn (rstn)
    );

    dut u_dut (
        .clk  (clk),
        .rstn (rstn)
    );

endmodule
