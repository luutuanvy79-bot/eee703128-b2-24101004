/* 
 * Họ và tên: Lưu Tuấn Vỹ
 * Msv: 24101004
 * Đề tài: C01 - Bộ giám sát cửa sổ giá trị hợp lệ 8-bit
 */

`default_nettype none

module tt_um_luutuanvy (
    input  wire [7:0] ui_in,    // Nhận dữ liệu mẫu: sample_in[7:0]
    output wire [7:0] uo_out,   // Trả về cờ phân loại: {4'b0, config_error, above, in_window, below}
    input  wire [7:0] uio_in,   // Nhận ngưỡng: min_val (ena=1) hoặc max_val (ena=0)
    output wire [7:0] uio_out,  // Không dùng
    output wire [7:0] uio_oe,   // 0 = Input, 1 = Output (Mặc định 0)
    input  wire       ena,      // Tín hiệu chọn nạp ngưỡng
    input  wire       clk,      // Xung nhịp hệ thống
    input  wire       rst_n     // Reset tích cực mức THẤP
);

    // Thanh ghi lưu cấu hình ngưỡng
    reg [7:0] min_val_reg;
    reg [7:0] max_val_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            min_val_reg <= 8'd0;
            max_val_reg <= 8'd255;
        end else begin
            if (ena) 
                min_val_reg <= uio_in;
            else 
                max_val_reg <= uio_in;
        end
    end

    // Dây nối ngõ ra từ lõi tổ hợp
    wire below_w, in_window_w, above_w, config_error_w;

    // Khởi tạo lõi C01 (đã vá lỗi từ khóa inside -> in_window)
    c01_window_monitor core_inst (
        .sample_in    (ui_in),
        .min_val      (min_val_reg),
        .max_val      (max_val_reg),
        .below        (below_w),
        .in_window    (in_window_w),
        .above        (above_w),
        .config_error (config_error_w)
    );

    // Gán tín hiệu ra chân vật lý
    assign uo_out  = {4'b0000, config_error_w, above_w, in_window_w, below_w};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule

// Lõi C01 nguyên bản viết lại bằng Verilog-2005 tiêu chuẩn để đảm bảo tương thích 100% CI
module c01_window_monitor (
    input  wire [7:0] sample_in,
    input  wire [7:0] min_val,
    input  wire [7:0] max_val,
    output reg        below,
    output reg        in_window,
    output reg        above,
    output reg        config_error
);
    always @(*) begin
        config_error = (min_val > max_val);

        // Gán giá trị mặc định để chống sinh latch
        below     = 1'b0;
        in_window = 1'b0;
        above     = 1'b0;

        if (!config_error) begin
            below     = (sample_in < min_val);
            above     = (sample_in > max_val);
            in_window = !below && !above;
        end
    end
endmodule
