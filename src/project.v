/*
 * EEE703128 - Bai kiem tra so 2 - De C01
 * Bo giam sat cua so gia tri hop le 8-bit
 * 1) c01_window_monitor : LOI so sanh, mach TO HOP THUAN (0 flip-flop)
 * 2) tt_um_eee703128_c01_24101004 : VO khung chan Tiny Tapeout,
 *    co thanh ghi nap nguong 2 lan (min roi max) qua uio_in
 */
`default_nettype none

module c01_window_monitor (
    input  wire [7:0] sample_in,
    input  wire [7:0] min_val,
    input  wire [7:0] max_val,
    output reg        below,
    output reg        in_window,
    output reg        above,
    output reg        config_error
);
    always @* begin
        config_error = (min_val > max_val);
        below        = 1'b0;
        in_window    = 1'b0;
        above        = 1'b0;
        if (!config_error) begin
            below     = (sample_in < min_val);
            above     = (sample_in > max_val);
            in_window = !below && !above;
        end
    end
endmodule

module tt_um_eee703128_c01_24101004 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    reg [1:0] phase;      // 0: cho nap min, 1: cho nap max, 2: da khoa
    reg [7:0] min_r;
    reg [7:0] max_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase <= 2'd0;
            min_r <= 8'd0;
            max_r <= 8'd255;
        end else begin
            case (phase)
                2'd0:    begin min_r <= uio_in; phase <= 2'd1; end
                2'd1:    begin max_r <= uio_in; phase <= 2'd2; end
                default: phase <= 2'd2;
            endcase
        end
    end

    wire below, in_window, above, config_error;

    c01_window_monitor u_core (
        .sample_in    (ui_in),
        .min_val      (min_r),
        .max_val      (max_r),
        .below        (below),
        .in_window    (in_window),
        .above        (above),
        .config_error (config_error)
    );

    assign uo_out  = {4'b0000, config_error, above, in_window, below};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, 1'b0};
endmodule

`default_nettype wire
