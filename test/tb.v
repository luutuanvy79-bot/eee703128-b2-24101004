/*
 * Họ và tên: Lưu Tuấn Vỹ
 * Mã sinh viên: 24101004
 * Testbench cho C01
 */

`timescale 1ns / 1ps

module tb;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    reg clk;
    reg ena;
    reg rst_n;
    
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_luutuanvy uut (
        .ui_in(ui_in), .uo_out(uo_out), .uio_in(uio_in),
        .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        clk = 0; ena = 1; rst_n = 0;
        ui_in = 0; uio_in = 0;
        
        #15 rst_n = 1; 
        
        uio_in = 8'd50;  #10; 
        uio_in = 8'd150; #10; 
        uio_in = 8'd0;   

        ui_in = 8'd20; #10;
        ui_in = 8'd50; #10;
        ui_in = 8'd100; #10;
        ui_in = 8'd150; #10;
        ui_in = 8'd200; #10;

        uio_in = 8'd200; #10; 
        uio_in = 8'd100; #10; 
        
        ui_in = 8'd150; #10;

        rst_n = 0; #10;
        rst_n = 1; #10;

        uio_in = 8'd10; #10; 
        uio_in = 8'd20; #10; 
        ui_in = 8'd5;   #10; 
        ui_in = 8'd15;  #10; 
        ui_in = 8'd25;  #10; 

        $display("MO PHONG HOAN TAT");
        $finish;
    end
endmodule
