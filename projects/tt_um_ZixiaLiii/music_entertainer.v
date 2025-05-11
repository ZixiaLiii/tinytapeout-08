`default_nettype none

module music_entertainer (
    input  wire clk,        // 25MHz clock
    input  wire rst_n,      // active-low reset
    output wire pwm         // PWM audio output
);

    // === PARAMETERS ===
    localparam INPUT_FREQ = 25000000;   // 25 MHz
    localparam SAMPLE_RATE = 200000;    // PWM sample rate
    localparam SAMPLE_BITS = $clog2(INPUT_FREQ / SAMPLE_RATE); // 7 bits
    localparam SAMPLE_SIZE = 1 << SAMPLE_BITS;   // 128
    localparam EXTRA_BITS = 8;
    localparam EXT_BITS = SAMPLE_BITS + EXTRA_BITS; // 15 bits
    localparam EXT_RANGE = SAMPLE_SIZE * (1 << EXTRA_BITS); // 128 * 256

    localparam TICKS_PER_BEAT = SAMPLE_RATE / 2;  // assume 120 BPM (1 beat = 0.5s)
    localparam EIGHTH_NOTE = TICKS_PER_BEAT / 2;
    localparam QUARTER_NOTE = TICKS_PER_BEAT;
    localparam HALF_NOTE = TICKS_PER_BEAT * 2;
    localparam NOTE_BITS = $clog2(HALF_NOTE);

    // === NOTE TABLE ===
    localparam C4 = 4'd0, D4 = 4'd1, E4 = 4'd2, F4 = 4'd3, G4 = 4'd4,
               A4 = 4'd5, B4 = 4'd6, C5 = 4'd7, D5 = 4'd8, E5 = 4'd9,
               F5 = 4'd10, G5 = 4'd11, REST = 4'd15;

    reg [15:0] freq_table [0:15];
    initial begin
        freq_table[C4] = EXT_RANGE * 262 / SAMPLE_RATE;
        freq_table[D4] = EXT_RANGE * 294 / SAMPLE_RATE;
        freq_table[E4] = EXT_RANGE * 330 / SAMPLE_RATE;
        freq_table[F4] = EXT_RANGE * 349 / SAMPLE_RATE;
        freq_table[G4] = EXT_RANGE * 392 / SAMPLE_RATE;
        freq_table[A4] = EXT_RANGE * 440 / SAMPLE_RATE;
        freq_table[B4] = EXT_RANGE * 494 / SAMPLE_RATE;
        freq_table[C5] = EXT_RANGE * 523 / SAMPLE_RATE;
        freq_table[D5] = EXT_RANGE * 587 / SAMPLE_RATE;
        freq_table[E5] = EXT_RANGE * 659 / SAMPLE_RATE;
        freq_table[F5] = EXT_RANGE * 698 / SAMPLE_RATE;
        freq_table[G5] = EXT_RANGE * 784 / SAMPLE_RATE;
        freq_table[REST] = 0;
    end

    // === MELODY ===
    localparam MELODY_LEN = 64;  // extended length
    reg [3:0] melody_note [0:MELODY_LEN-1];
    reg [NOTE_BITS-1:0] melody_len [0:MELODY_LEN-1];

    initial begin
        melody_note[ 0] = E4; melody_len[ 0] = EIGHTH_NOTE;
        melody_note[ 1] = G4; melody_len[ 1] = EIGHTH_NOTE;
        melody_note[ 2] = C5; melody_len[ 2] = QUARTER_NOTE;
        melody_note[ 3] = E5; melody_len[ 3] = EIGHTH_NOTE;
        melody_note[ 4] = G5; melody_len[ 4] = EIGHTH_NOTE;
        melody_note[ 5] = B4; melody_len[ 5] = QUARTER_NOTE;
        melody_note[ 6] = G4; melody_len[ 6] = EIGHTH_NOTE;
        melody_note[ 7] = E4; melody_len[ 7] = EIGHTH_NOTE;
        melody_note[ 8] = C4; melody_len[ 8] = QUARTER_NOTE;
        melody_note[ 9] = E4; melody_len[ 9] = QUARTER_NOTE;

        melody_note[10] = G4; melody_len[10] = QUARTER_NOTE;
        melody_note[11] = E4; melody_len[11] = EIGHTH_NOTE;
        melody_note[12] = G4; melody_len[12] = EIGHTH_NOTE;
        melody_note[13] = C5; melody_len[13] = QUARTER_NOTE;
        melody_note[14] = E5; melody_len[14] = EIGHTH_NOTE;
        melody_note[15] = G5; melody_len[15] = EIGHTH_NOTE;
        melody_note[16] = B4; melody_len[16] = QUARTER_NOTE;
        melody_note[17] = G4; melody_len[17] = EIGHTH_NOTE;
        melody_note[18] = E4; melody_len[18] = EIGHTH_NOTE;
        melody_note[19] = C4; melody_len[19] = QUARTER_NOTE;

        melody_note[20] = G4; melody_len[20] = QUARTER_NOTE;
        melody_note[21] = C5; melody_len[21] = QUARTER_NOTE;
        melody_note[22] = B4; melody_len[22] = EIGHTH_NOTE;
        melody_note[23] = D5; melody_len[23] = EIGHTH_NOTE;
        melody_note[24] = G5; melody_len[24] = QUARTER_NOTE;
        melody_note[25] = F5; melody_len[25] = EIGHTH_NOTE;
        melody_note[26] = D5; melody_len[26] = EIGHTH_NOTE;
        melody_note[27] = B4; melody_len[27] = QUARTER_NOTE;
        melody_note[28] = G4; melody_len[28] = EIGHTH_NOTE;
        melody_note[29] = B4; melody_len[29] = EIGHTH_NOTE;

        melody_note[30] = D5; melody_len[30] = QUARTER_NOTE;
        melody_note[31] = F5; melody_len[31] = QUARTER_NOTE;
        melody_note[32] = E5; melody_len[32] = QUARTER_NOTE;
        melody_note[33] = D5; melody_len[33] = EIGHTH_NOTE;
        melody_note[34] = B4; melody_len[34] = EIGHTH_NOTE;
        melody_note[35] = G4; melody_len[35] = QUARTER_NOTE;
        melody_note[36] = F4; melody_len[36] = QUARTER_NOTE;
        melody_note[37] = D4; melody_len[37] = QUARTER_NOTE;
        melody_note[38] = G4; melody_len[38] = HALF_NOTE;
        melody_note[39] = REST; melody_len[39] = QUARTER_NOTE;

        melody_note[40] = C5; melody_len[40] = EIGHTH_NOTE;
        melody_note[41] = C5; melody_len[41] = EIGHTH_NOTE;
        melody_note[42] = D5; melody_len[42] = EIGHTH_NOTE;
        melody_note[43] = E5; melody_len[43] = EIGHTH_NOTE;
        melody_note[44] = D5; melody_len[44] = EIGHTH_NOTE;
        melody_note[45] = C5; melody_len[45] = EIGHTH_NOTE;
        melody_note[46] = B4; melody_len[46] = EIGHTH_NOTE;
        melody_note[47] = G4; melody_len[47] = QUARTER_NOTE;

        melody_note[48] = G4; melody_len[48] = EIGHTH_NOTE;
        melody_note[49] = A4; melody_len[49] = EIGHTH_NOTE;
        melody_note[50] = B4; melody_len[50] = QUARTER_NOTE;
        melody_note[51] = D5; melody_len[51] = EIGHTH_NOTE;
        melody_note[52] = C5; melody_len[52] = EIGHTH_NOTE;
        melody_note[53] = A4; melody_len[53] = QUARTER_NOTE;
        melody_note[54] = F4; melody_len[54] = EIGHTH_NOTE;
        melody_note[55] = G4; melody_len[55] = EIGHTH_NOTE;

        melody_note[56] = A4; melody_len[56] = QUARTER_NOTE;
        melody_note[57] = C5; melody_len[57] = EIGHTH_NOTE;
        melody_note[58] = B4; melody_len[58] = EIGHTH_NOTE;
        melody_note[59] = G4; melody_len[59] = QUARTER_NOTE;
        melody_note[60] = E4; melody_len[60] = EIGHTH_NOTE;
        melody_note[61] = G4; melody_len[61] = EIGHTH_NOTE;
        melody_note[62] = C5; melody_len[62] = HALF_NOTE;
        melody_note[63] = REST; melody_len[63] = QUARTER_NOTE;
    end

    // === STATE ===
    reg [5:0] idx;
    reg [NOTE_BITS-1:0] note_cnt;
    reg [EXT_BITS-1:0] phase_accum;
    reg [SAMPLE_BITS-1:0] pwm_pos;

    wire [15:0] increment = freq_table[melody_note[idx]];
    wire [SAMPLE_BITS-1:0] sample = phase_accum[EXT_BITS-1 -: SAMPLE_BITS];
    assign pwm = (pwm_pos < sample);

    always @(posedge clk) begin
        if (!rst_n) begin
            idx <= 0;
            note_cnt <= 0;
            pwm_pos <= 0;
            phase_accum <= 0;
        end else begin
            if (pwm_pos == SAMPLE_SIZE - 1) begin
                pwm_pos <= 0;
                note_cnt <= note_cnt + 1;
                if (note_cnt >= melody_len[idx]) begin
                    note_cnt <= 0;
                    idx <= (idx == MELODY_LEN-1) ? 0 : idx + 1;
                end
                if (melody_note[idx] != REST)
                    phase_accum <= phase_accum + increment;
            end else begin
                pwm_pos <= pwm_pos + 1;
            end
        end
    end

endmodule







