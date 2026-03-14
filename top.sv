module top;

    logic clk;
    logic rst;

    tb_top u_tb (
    );

    dut u_dut (
    );

	initial begin
		$display("Hello world");
	end

endmodule
