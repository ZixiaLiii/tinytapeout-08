`default_nettype none
`timescale 1ns / 1ps

module sunrise #(
    parameter XW = 10,
    parameter YW = 9,
    parameter COLRW = 12
)(
    input wire clk_pix,
    input wire rst,
    input wire line,
    input wire [XW-1:0] sx,
    input wire [YW-1:0] sy,
    input wire [7:0] fade_level,
    input wire direction,
    output reg [COLRW-1:0] sun_colr
);

    localparam [COLRW-1:0] COLOR_SUN = 12'hFF0;
    localparam [9:0] RADIUS = 24;

    reg [9:0] sun_x;
    reg [8:0] sun_y;

    always @(*) begin
        if (direction == 1'b1 || fade_level <= 8'd63 || fade_level > 8'd255) begin
            sun_x = 10'd0;
            sun_y = 9'd500;
        end else if (fade_level <= 8'd112) begin
            sun_x = 640 - ((fade_level - 8'd64) * 80 / (112 - 64));
            sun_y = 310 - ((fade_level - 8'd64) * 210 / (112 - 64));
        end else if (fade_level <= 8'd247) begin
            sun_x = 560 - ((fade_level - 8'd113) * 400 / (247 - 113));
            sun_y = 100;
        end else begin
            sun_x = 160 - ((fade_level - 8'd248) * 80 / (255 - 248));
            sun_y = 100 + ((fade_level - 8'd248) * 220 / (255 - 248));
        end
    end

    wire signed [11:0] dx = sx - sun_x;
    wire signed [11:0] dy = sy - sun_y;
    wire [23:0] dist2 = dx * dx + dy * dy;

    always @(*) begin
        if (sun_y < 9'd320 && dist2 <= RADIUS * RADIUS)
            sun_colr = COLOR_SUN;
        else
            sun_colr = 12'h000;
    end

endmodule


