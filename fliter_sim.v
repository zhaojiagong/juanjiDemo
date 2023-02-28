`timescale 1ns / 1ps
module fliter_sim();
reg             sys_clk;
reg             sys_rst_n;

initial begin
sys_clk = 0;
sys_rst_n = 0;
#100
sys_rst_n = 1;
end

always #10 sys_clk = ~sys_clk;

filter_3x3 u_filter_3x3(
        .sys_clk    (sys_clk  ),
        .sys_rst_n  (sys_rst_n),
        .R_oData    (R_oData  ), 
        .G_oData    (G_oData  ), 
        .B_oData    (B_oData  )
);

endmodule
