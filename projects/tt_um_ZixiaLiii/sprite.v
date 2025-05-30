`default_nettype none
`timescale 1ns / 1ps

module sprite #(
    parameter CORDW = 16,      // signed coordinate width (bits)
    parameter H_RES = 640,     // horizontal screen resolution (pixels)
    parameter SX_OFFS = 2,     // horizontal screen offset (pixels)
    parameter SPR_FILE = "",   // sprite bitmap file ($readmemh format)
    parameter SPR_WIDTH = 8,   // sprite bitmap width in pixels
    parameter SPR_HEIGHT = 8,  // sprite bitmap height in pixels
    parameter SPR_SCALE = 0,   // scale factor: 0=1x, 1=2x, 2=4x, etc.
    parameter SPR_DATAW = 1    // data width: bits per pixel
)(
    input  wire clk,                            // clock
    input  wire rst,                            // reset
    input  wire line,                           // start of active screen line
    input  wire signed [CORDW-1:0] sx, sy,       // screen position
    input  wire signed [CORDW-1:0] sprx, spry,   // sprite position
    output reg  [SPR_DATAW-1:0] pix,             // pixel colour index
    output reg  drawing                         // drawing at position (sx,sy)
);

    // sprite bitmap ROM
    localparam SPR_ROM_DEPTH = SPR_WIDTH * SPR_HEIGHT;
    wire [$clog2(SPR_ROM_DEPTH)-1:0] spr_rom_addr_wire;
    wire [SPR_DATAW-1:0] spr_rom_data;

    reg [$clog2(SPR_ROM_DEPTH)-1:0] spr_rom_addr;
    rom_async #(
        .WIDTH(SPR_DATAW),
        .DEPTH(SPR_ROM_DEPTH),
        .INIT_F(SPR_FILE)
    ) spr_rom (
        .addr(spr_rom_addr),
        .data(spr_rom_data)
    );

    reg [$clog2(SPR_WIDTH)-1:0] bmap_x;
    reg [SPR_SCALE:0] cnt_x;

    reg signed [CORDW-1:0] sprx_r, spry_r;

    reg signed [CORDW-1:0] spr_diff;
    reg spr_active;
    reg spr_begin;
    reg spr_end;
    reg line_end;

    reg [2:0] state;
    localparam IDLE      = 3'd0;
    localparam REG_POS   = 3'd1;
    localparam ACTIVE    = 3'd2;
    localparam WAIT_POS  = 3'd3;
    localparam SPR_LINE  = 3'd4;
    localparam WAIT_DATA = 3'd5;

    // combinational logic block
    always @* begin
        spr_diff = (sy - spry_r) >>> SPR_SCALE;
        spr_active = (spr_diff >= 0) && (spr_diff < SPR_HEIGHT);
        spr_begin = (sx >= sprx_r - SX_OFFS);
        spr_end = (bmap_x == SPR_WIDTH-1);
        line_end = (sx == H_RES - SX_OFFS);
    end

    // sequential logic block
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            spr_rom_addr <= 0;
            bmap_x <= 0;
            cnt_x <= 0;
            pix <= 0;
            drawing <= 0;
        end else begin
            if (line) begin
                state <= REG_POS;
                pix <= 0;
                drawing <= 0;
            end else begin
                case (state)
                    REG_POS: begin
                        state <= ACTIVE;
                        sprx_r <= sprx;
                        spry_r <= spry;
                    end

                    ACTIVE: begin
                        if (spr_active)
                            state <= WAIT_POS;
                        else
                            state <= IDLE;
                    end

                    WAIT_POS: begin
                        if (spr_begin) begin
                            state <= SPR_LINE;
                            spr_rom_addr <= spr_diff * SPR_WIDTH + (sx - sprx_r) + SX_OFFS;
                            bmap_x <= 0;
                            cnt_x <= 0;
                        end
                    end

                    SPR_LINE: begin
                        pix <= spr_rom_data;
                        drawing <= 1;
                        if (SPR_SCALE == 0 || cnt_x == (1<<SPR_SCALE)-1) begin
                            if (spr_end)
                                state <= WAIT_DATA;
                            spr_rom_addr <= spr_rom_addr + 1;
                            bmap_x <= bmap_x + 1;
                            cnt_x <= 0;
                        end else begin
                            cnt_x <= cnt_x + 1;
                        end
                        if (line_end) begin
                            state <= WAIT_DATA;
                        end
                    end

                    WAIT_DATA: begin
                        state <= IDLE;
                        pix <= 0;
                        drawing <= 0;
                    end

                    default: begin
                        state <= IDLE;
                    end
                endcase
            end
        end
    end

endmodule

