
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

    wire config_error;
    wire below;
    wire in_window;
    wire above;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            min_reg    <= 8'd0;
            max_reg    <= 8'd255;
            sel_toggle <= 1'b0;
        end else if (ena) begin
            if (sel_toggle == 1'b0) begin
                min_reg    <= uio_in;
                sel_toggle <= 1'b1;
            end else begin
                max_reg    <= uio_in;
                sel_toggle <= 1'b0;
            end
        end
    end

    assign config_error = (min_reg > max_reg);
    assign below = (ui_in < min_reg);
    assign above = (ui_in > max_reg);
    assign in_window = (ui_in >= min_reg) &&
                       (ui_in <= max_reg);

    assign uo_out[0] = !config_error && below;
    assign uo_out[1] = !config_error && in_window;
    assign uo_out[2] = !config_error && above;
    assign uo_out[3] = config_error;
    assign uo_out[7:4] = 4'b0000;

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule

`default_nettype wire
