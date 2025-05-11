`default_nettype none

module music_entertainer (
    input  wire clk,       // 25 MHz clock
    input  wire rst_n,     // active-low reset
    output wire pwm        // 1-bit PWM audio output
);

    // === PARAMETERS ===
    localparam INPUT_FREQ   = 25000000;
    localparam SAMPLE_RATE  = 200000;
    localparam SAMPLE_BITS  = $clog2(INPUT_FREQ / SAMPLE_RATE);  // 7
    localparam SAMPLE_SIZE  = 1 << SAMPLE_BITS;                  // 128
    localparam EXTRA_BITS   = 8;
    localparam EXT_BITS     = SAMPLE_BITS + EXTRA_BITS;          // 15
    localparam EXT_RANGE    = SAMPLE_SIZE * (1 << EXTRA_BITS);   // 128 * 256

    localparam TICKS_PER_BEAT = SAMPLE_RATE / 2;  // 0.5s per beat
    localparam EIGHTH_NOTE  = TICKS_PER_BEAT / 2;
    localparam QUARTER_NOTE = TICKS_PER_BEAT;
    localparam HALF_NOTE    = TICKS_PER_BEAT * 2;
    localparam NOTE_BITS    = $clog2(HALF_NOTE);  // 10 bits

    localparam MELODY_LEN = 64;

    // === NOTE IDs ===
    localparam C4 = 4'd0, D4 = 4'd1, E4 = 4'd2, F4 = 4'd3, G4 = 4'd4,
               A4 = 4'd5, B4 = 4'd6, C5 = 4'd7, D5 = 4'd8, E5 = 4'd9,
               F5 = 4'd10, G5 = 4'd11, REST = 4'd15;

    // === STATE REGISTERS ===
    reg  [5:0] idx;
    reg  [NOTE_BITS-1:0] note_cnt;
    reg  [EXT_BITS-1:0] phase_accum;
    reg  [SAMPLE_BITS-1:0] pwm_pos;

    // === ROM: Melody Note and Length (combinational) ===
    reg [3:0] current_note;
    reg [NOTE_BITS-1:0] current_len;
    always @(*) begin
        case (idx)
            6'd0:  begin current_note = E4; current_len = EIGHTH_NOTE; end
            6'd1:  begin current_note = G4; current_len = EIGHTH_NOTE; end
            6'd2:  begin current_note = C5; current_len = QUARTER_NOTE; end
            6'd3:  begin current_note = E5; current_len = EIGHTH_NOTE; end
            6'd4:  begin current_note = G5; current_len = EIGHTH_NOTE; end
            6'd5:  begin current_note = B4; current_len = QUARTER_NOTE; end
            6'd6:  begin current_note = G4; current_len = EIGHTH_NOTE; end
            6'd7:  begin current_note = E4; current_len = EIGHTH_NOTE; end
            6'd8:  begin current_note = C4; current_len = QUARTER_NOTE; end
            6'd9:  begin current_note = E4; current_len = QUARTER_NOTE; end

            6'd10: begin current_note = G4; current_len = QUARTER_NOTE; end
            6'd11: begin current_note = E4; current_len = EIGHTH_NOTE; end
            6'd12: begin current_note = G4; current_len = EIGHTH_NOTE; end
            6'd13: begin current_note = C5; current_len = QUARTER_NOTE; end
            6'd14: begin current_note = E5; current_len = EIGHTH_NOTE; end
            6'd15: begin current_note = G5; current_len = EIGHTH_NOTE; end
            6'd16: begin current_note = B4; current_len = QUARTER_NOTE; end
            6'd17: begin current_note = G4; current_len = EIGHTH_NOTE; end
            6'd18: begin current_note = E4; current_len = EIGHTH_NOTE; end
            6'd19: begin current_note = C4; current_len = QUARTER_NOTE; end

            6'd20: begin current_note = G4; current_len = QUARTER_NOTE; end
            6'd21: begin current_note = C5; current_len = QUARTER_NOTE; end
            6'd22: begin current_note = B4; current_len = EIGHTH_NOTE; end
            6'd23: begin current_note = D5; current_len = EIGHTH_NOTE; end
            6'd24: begin current_note = G5; current_len = QUARTER_NOTE; end
            6'd25: begin current_note = F5; current_len = EIGHTH_NOTE; end
            6'd26: begin current_note = D5; current_len = EIGHTH_NOTE; end
            6'd27: begin current_note = B4; current_len = QUARTER_NOTE; end
            6'd28: begin current_note = G4; current_len = EIGHTH_NOTE; end
            6'd29: begin current_note = B4; current_len = EIGHTH_NOTE; end

            6'd30: begin current_note = D5; current_len = QUARTER_NOTE; end
            6'd31: begin current_note = F5; current_len = QUARTER_NOTE; end
            6'd32: begin current_note = E5; current_len = QUARTER_NOTE; end
            6'd33: begin current_note = D5; current_len = EIGHTH_NOTE; end
            6'd34: begin current_note = B4; current_len = EIGHTH_NOTE; end
            6'd35: begin current_note = G4; current_len = QUARTER_NOTE; end
            6'd36: begin current_note = F4; current_len = QUARTER_NOTE; end
            6'd37: begin current_note = D4; current_len = QUARTER_NOTE; end
            6'd38: begin current_note = G4; current_len = HALF_NOTE; end
            6'd39: begin current_note = REST; current_len = QUARTER_NOTE; end

            6'd40: begin current_note = C5; current_len = EIGHTH_NOTE; end
            6'd41: begin current_note = C5; current_len = EIGHTH_NOTE; end
            6'd42: begin current_note = D5; current_len = EIGHTH_NOTE; end
            6'd43: begin current_note = E5; current_len = EIGHTH_NOTE; end
            6'd44: begin current_note = D5; current_len = EIGHTH_NOTE; end
            6'd45: begin current_note = C5; current_len = EIGHTH_NOTE; end
            6'd46: begin current_note = B4; current_len = EIGHTH_NOTE; end
            6'd47: begin current_note = G4; current_len = QUARTER_NOTE; end

            6'd48: begin current_note = G4; current_len = EIGHTH_NOTE; end
            6'd49: begin current_note = A4; current_len = EIGHTH_NOTE; end
            6'd50: begin current_note = B4; current_len = QUARTER_NOTE; end
            6'd51: begin current_note = D5; current_len = EIGHTH_NOTE; end
            6'd52: begin current_note = C5; current_len = EIGHTH_NOTE; end
            6'd53: begin current_note = A4; current_len = QUARTER_NOTE; end
            6'd54: begin current_note = F4; current_len = EIGHTH_NOTE; end
            6'd55: begin current_note = G4; current_len = EIGHTH_NOTE; end

            6'd56: begin current_note = A4; current_len = QUARTER_NOTE; end
            6'd57: begin current_note = C5; current_len = EIGHTH_NOTE; end
            6'd58: begin current_note = B4; current_len = EIGHTH_NOTE; end
            6'd59: begin current_note = G4; current_len = QUARTER_NOTE; end
            6'd60: begin current_note = E4; current_len = EIGHTH_NOTE; end
            6'd61: begin current_note = G4; current_len = EIGHTH_NOTE; end
            6'd62: begin current_note = C5; current_len = HALF_NOTE; end
            default: begin current_note = REST; current_len = QUARTER_NOTE; end
        endcase
    end
endmodule
