/* 
 * Họ và tên: Lưu Tuấn Vỹ
 * Msv: 24101004
 * Đề tài: C01 - Bộ giám sát cửa sổ giá trị hợp lệ 8-bit
 */

`default_nettype none
`timescale 1ns/1ps

module tb;
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Khởi tạo DUT
    tt_um_luutuanvy dut (
        .ui_in  (ui_in),
        .uo_out (uo_out),
        .uio_in (uio_in),
        .uio_out(uio_out),
        .uio_oe (uio_oe),
        .ena    (ena),
        .clk    (clk),
        .rst_n  (rst_n)
    );

    // Tạo xung Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Bóc tách tín hiệu đầu ra
    wire below        = uo_out[0];
    wire in_window    = uo_out[1];
    wire above        = uo_out[2];
    wire config_error = uo_out[3];

    // Cấu trúc mô hình kiểm tra (Reference Logic)
    reg below_ref, in_window_ref, above_ref, config_error_ref;
    reg [7:0] current_min, current_max;

    always @(*) begin
        config_error_ref = (current_min > current_max);
        below_ref     = 1'b0;
        in_window_ref = 1'b0;
        above_ref     = 1'b0;
        if (!config_error_ref) begin
            if (ui_in < current_min) below_ref = 1'b1;
            else if (ui_in > current_max) above_ref = 1'b1;
            else in_window_ref = 1'b1;
        end
    end

    // Task tự động hóa kiểm tra (mô phỏng quá trình nạp 2 nhịp)
    task automatic check_case(input [7:0] s, input [7:0] lo, input [7:0] hi);
        begin
            // Nhịp 1: Nạp min_val (ena = 1)
            ena = 1; uio_in = lo;
            @(posedge clk);
            
            // Nhịp 2: Nạp max_val (ena = 0)
            ena = 0; uio_in = hi;
            @(posedge clk);
            
            current_min = lo;
            current_max = hi;

            // Nhịp 3: Đưa mẫu vào và chờ logic tổ hợp ổn định
            ui_in = s;
            #1;

            if (below !== below_ref || in_window !== in_window_ref || above !== above_ref || config_error !== config_error_ref) begin
                $display("FAIL: s=%0d, lo=%0d, hi=%0d | KQ: cfg=%b, abv=%b, in=%b, blw=%b", 
                          s, lo, hi, config_error, above, in_window, below);
            end
        end
    endtask

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        // Chuẩn bị Reset
        rst_n = 0; ui_in = 0; uio_in = 0; ena = 0;
        @(posedge clk);
        @(posedge clk);
        rst_n = 1;

        // Các ca kiểm thử bắt buộc Charter
        check_case(8'd49,  8'd50, 8'd100);
        check_case(8'd50,  8'd50, 8'd100);
        check_case(8'd75,  8'd50, 8'd100);
        check_case(8'd100, 8'd50, 8'd100);
        check_case(8'd101, 8'd50, 8'd100);
        check_case(8'd75,  8'd100,8'd50);

        // L-3: Biên cửa sổ hẹp
        check_case(8'd99,  8'd100, 8'd100);
        check_case(8'd100, 8'd100, 8'd100);
        check_case(8'd101, 8'd100, 8'd100);

        // L-2: Cấu hình sai sát biên
        check_case(8'd99,  8'd100, 8'd99);
        check_case(8'd100, 8'd100, 8'd99);
        check_case(8'd101, 8'd100, 8'd99);

        // L-1: Cấu hình cấu hình sai đại diện
        check_case(8'd0, 8'd10, 8'd5);
        check_case(8'd255, 8'd255, 8'd0);

        #20;
        $display("C01 functional verification PASS");
        $finish;
    end
endmodule
