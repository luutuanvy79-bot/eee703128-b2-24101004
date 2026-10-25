/*
 * Họ và tên: Lưu Tuấn Vỹ
 * Mã sinh viên: 24101004
 * Đề tài: C01 - Bộ giám sát cửa sổ giá trị hợp lệ 8-bit
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

    assign uio_oe  = 8'b0000_0000;
    assign uio_out = 8'b0000_0000;

    reg [7:0] min_reg;
    reg [7:0] max_reg;
    reg       sel_toggle; 

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

    wire [7:0] sample = ui_in;
    
    wire is_error  = (min_reg > max_reg); 
    wire is_under  = (sample < min_reg);
    wire is_over   = (sample > max_reg);
    wire is_inside = (sample >= min_reg) && (sample <= max_reg);

    assign uo_out[0] = is_error ? 1'b0 : is_under;  
    assign uo_out[1] = is_error ? 1'b0 : is_inside; 
    assign uo_out[2] = is_error ? 1'b0 : is_over;   
    assign uo_out[3] = is_error;                    
    
    assign uo_out[7:4] = 4'b0000; 

endmodule
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
