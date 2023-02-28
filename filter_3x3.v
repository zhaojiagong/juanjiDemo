`timescale 1ns / 1ps
module filter_3x3(
    input                  sys_clk,
    input                  sys_rst_n,
    //input      [8-1:0]     R_iData, G_iData, B_iData,
    output  [16-1:0]     R_oData, G_oData, B_oData
);
parameter out_max = 16;
reg   [8-1:0] cnt;
reg  [8-1:0] R_conv_input [6-1:0][6-1:0];
reg  [8-1:0] G_conv_input [6-1:0][6-1:0];
reg  [8-1:0] B_conv_input [6-1:0][6-1:0];
reg  [8-1:0] R_iData, G_iData, B_iData;
reg   finish_flag;
integer k,l;
reg [4:0]   i,j;  
reg [4:0]   i_conv,j_conv;
reg [8-1:0] conv_cnt;

wire [7:0] R_conv_window0,R_conv_window1,R_conv_window2,R_conv_window3,R_conv_window4,R_conv_window5,R_conv_window6,R_conv_window7,R_conv_window8;
wire [7:0] G_conv_window0,G_conv_window1,G_conv_window2,G_conv_window3,G_conv_window4,G_conv_window5,G_conv_window6,G_conv_window7,G_conv_window8;
wire [7:0] B_conv_window0,B_conv_window1,B_conv_window2,B_conv_window3,B_conv_window4,B_conv_window5,B_conv_window6,B_conv_window7,B_conv_window8;
//定义三通道卷积窗口
assign R_conv_window0 =  finish_flag ? R_conv_input[i_conv][j_conv]     :1'b0 ;
assign R_conv_window1 =  finish_flag ? R_conv_input[i_conv][j_conv+1]   :1'b0 ;
assign R_conv_window2 =  finish_flag ? R_conv_input[i_conv][j_conv+2]   :1'b0 ;
assign R_conv_window3 =  finish_flag ? R_conv_input[i_conv+1][j_conv]  :1'b0 ;
assign R_conv_window4 =  finish_flag ? R_conv_input[i_conv+1][j_conv+1] :1'b0 ;
assign R_conv_window5 =  finish_flag ? R_conv_input[i_conv+1][j_conv+2] :1'b0 ;
assign R_conv_window6 =  finish_flag ? R_conv_input[i_conv+2][j_conv]   :1'b0 ;
assign R_conv_window7 =  finish_flag ? R_conv_input[i_conv+2][j_conv+1] :1'b0 ;
assign R_conv_window8 =  finish_flag ? R_conv_input[i_conv+2][j_conv+2] :1'b0 ;
                                                                               
assign G_conv_window0 =  finish_flag ? G_conv_input[i_conv][j_conv]     :1'b0 ;
assign G_conv_window1 =  finish_flag ? G_conv_input[i_conv][j_conv+1]   :1'b0 ;
assign G_conv_window2 =  finish_flag ? G_conv_input[i_conv][j_conv+2]   :1'b0 ;
assign G_conv_window3 =  finish_flag ? G_conv_input[i_conv+1][j_conv]   :1'b0 ;
assign G_conv_window4 =  finish_flag ? G_conv_input[i_conv+1][j_conv+1] :1'b0 ;
assign G_conv_window5 =  finish_flag ? G_conv_input[i_conv+1][j_conv+2] :1'b0 ;
assign G_conv_window6 =  finish_flag ? G_conv_input[i_conv+2][j_conv]   :1'b0 ;
assign G_conv_window7 =  finish_flag ? G_conv_input[i_conv+2][j_conv+1] :1'b0 ;
assign G_conv_window8 =  finish_flag ? G_conv_input[i_conv+2][j_conv+2] :1'b0 ;
                                                                              
assign  B_conv_window0 = finish_flag ? B_conv_input[i_conv][j_conv]     :1'b0 ;
assign  B_conv_window1 = finish_flag ? B_conv_input[i_conv][j_conv+1]   :1'b0 ;
assign  B_conv_window2 = finish_flag ? B_conv_input[i_conv][j_conv+2]   :1'b0 ;
assign  B_conv_window3 = finish_flag ? B_conv_input[i_conv+1][j_conv]   :1'b0 ;
assign  B_conv_window4 = finish_flag ? B_conv_input[i_conv+1][j_conv+1] :1'b0 ;
assign  B_conv_window5 = finish_flag ? B_conv_input[i_conv+1][j_conv+2] :1'b0 ;
assign  B_conv_window6 = finish_flag ? B_conv_input[i_conv+2][j_conv]   :1'b0 ;
assign  B_conv_window7 = finish_flag ? B_conv_input[i_conv+2][j_conv+1] :1'b0 ;
assign  B_conv_window8 = finish_flag ? B_conv_input[i_conv+2][j_conv+2] :1'b0 ;

//  3*3卷积核
// [   1  0   +1  ]   
// [   -2  0   +1  ]  
// [   1  0   +1  ]
assign R_oData = R_conv_window2 + R_conv_window0 +R_conv_window5-2*R_conv_window3 + R_conv_window8 + R_conv_window6;
assign G_oData = G_conv_window2 + G_conv_window0 +G_conv_window5-2*G_conv_window3 + G_conv_window8 + G_conv_window6;
assign B_oData = B_conv_window2 + B_conv_window0 +B_conv_window5-2*B_conv_window3 + B_conv_window8 + B_conv_window6;

always @(posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)begin
         cnt <= 8'b0;
         finish_flag <= 1'b0;  
    end     
    else if(cnt < 8'b100100)
         cnt <= cnt + 1'b1;
    else  begin
         cnt <= cnt;
         finish_flag <= 1'b1;
    end 
end

always @(posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)begin
         i <= 1'b0;
         j <= 1'b0; 
     end else 
     begin
        i <= cnt / 6;
        j <= cnt % 6;
     end
end

always @(posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)begin
        for(k = 0; k < 6; k = k + 1)
        for(l = 0; l < 6; l = l + 1)
        begin
         R_conv_input[k][l] <= 1'b0;
         G_conv_input[k][l] <= 1'b0;
         B_conv_input[k][l] <= 1'b0; 
        end
    end
    else begin
         R_conv_input[i][j] <= R_iData;
         G_conv_input[i][j] <= G_iData;
         B_conv_input[i][j] <= B_iData;  
         end  
end

always @(posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)
      begin
        R_iData <=  8'b0;
        G_iData <=  8'b0;
        B_iData <=  8'b0;
      end
      else begin
      R_iData <=  cnt;
      G_iData <=  36 - cnt;
      B_iData <=  cnt + 2'b10;
      end     
end

always @(posedge sys_clk or negedge sys_rst_n )begin
    if(!finish_flag)begin
        conv_cnt <= 1'b0; 
     end else 
     if(conv_cnt < 5'b01111)
        conv_cnt <= conv_cnt + 1'b1;
     else conv_cnt <= conv_cnt;    
end

always @(posedge sys_clk or negedge sys_rst_n )begin
    if(!finish_flag)begin
         i_conv <= 1'b0;
         j_conv <= 1'b0; 
     end else 
     begin
        i_conv <= conv_cnt / 4;
        j_conv <= conv_cnt % 4;
     end
end

endmodule

