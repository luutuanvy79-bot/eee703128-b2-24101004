
/*
 * Ho va ten: Luu Tuan Vy
 * Ma sinh vien: 24101004
 * De tai: C01 - Bo giam sat cua so gia tri hop le 8-bit
 */

`default_nettype none

module tt_um_luutuanvy (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    reg [7:0] min_reg;
    reg [7:0] max_reg;
    reg       sel_toggle;

    wire [7:0] sample;
    wire       is_error;
    wire       is_under;
    wire       is_over;
    wire       is_inside;

    assign sample = ui_in;

    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            min_reg    <= 8'd0;
            max_reg    <= 8'd255;
            sel_toggle <= 1'b0;
        end else if (ena) begin
            if (!sel_toggle) begin
                min_reg    <= uio_in;
                sel_toggle <= 1'b1;
            end else begin
                max_reg    <= uio_in;
                sel_toggle <= 1'b0;
            end
        end
    end

    assign is_error  = (min_reg > max_reg);
    assign is_under  = (sample < min_reg);
    assign is_over   = (sample > max_reg);
    assign is_inside = (sample >= min_reg) &&
                       (sample <= max_reg);

    assign uo_out[0] = !is_error && is_under;
    assign uo_out[1] = !is_error && is_inside;
    assign uo_out[2] = !is_error && is_over;
    assign uo_out[3] = is_error;
    assign uo_out[7:4] = 4'b0000;

endmodule

`default_nettype wire
