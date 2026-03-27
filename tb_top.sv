module tb_top(
    output logic clk,
    output logic rstn
);

    initial begin
        $display("[%0t] Simulation started", $time);
        clk = 1'b0;
        rstn = 1'b0;

        $display("[%0t] Reset asserted", $time);

        #20;
        rstn = 1'b1;
        $display("[%0t] Reset deasserted", $time);
	
        #100;
        $finish;	    

    end

    always #5 clk = ~clk;

endmodule
