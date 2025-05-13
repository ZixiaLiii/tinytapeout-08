`timescale 1ns / 1ps

module music_entertainer (
    input clk,
    output reg AUD_PWM,
    output AUD_SD
);

assign AUD_SD = 1'b1;

// === Frequency table based on 25 MHz clock, using your original tone frequencies ===
reg [31:0] freq_div;
reg [7:0] melody_index = 0;
reg [5:0] note_code;
reg silent;

always @(*) begin
    if (silent) begin
        freq_div = 0;
    end else begin
        case (note_code)
            6'd0:  freq_div = 0;      // REST
            6'd1:  freq_div = 47709;  // C4
            6'd2:  freq_div = 42517;  // D4
            6'd3:  freq_div = 37878;  // E4
            6'd4:  freq_div = 35816;  // F4
            6'd5:  freq_div = 31887;  // G4
            6'd6:  freq_div = 28409;  // A4
            6'd7:  freq_div = 25303;  // B4
            6'd8:  freq_div = 23900;  // C5
            6'd9:  freq_div = 21294;  // D5
            6'd10: freq_div = 18968;  // E5
            6'd11: freq_div = 17908;  // F5
            6'd12: freq_div = 15943;  // G5
            default: freq_div = 0;
        endcase
    end
end

// === Melody: The Entertainer ===
// 64 notes from your original melody, code mapped to note_code table above
always @(*) begin
    case (melody_index)
        8'd0:  begin note_code = 6'd3;  silent = 0; end // E4
        8'd1:  begin note_code = 6'd5;  silent = 0; end // G4
        8'd2:  begin note_code = 6'd8;  silent = 0; end // C5
        8'd3:  begin note_code = 6'd10; silent = 0; end // E5
        8'd4:  begin note_code = 6'd12; silent = 0; end // G5
        8'd5:  begin note_code = 6'd7;  silent = 0; end // B4
        8'd6:  begin note_code = 6'd5;  silent = 0; end // G4
        8'd7:  begin note_code = 6'd3;  silent = 0; end // E4
        8'd8:  begin note_code = 6'd1;  silent = 0; end // C4
        8'd9:  begin note_code = 6'd3;  silent = 0; end // E4
        8'd10: begin note_code = 6'd5;  silent = 0; end // G4
        8'd11: begin note_code = 6'd3;  silent = 0; end // E4
        8'd12: begin note_code = 6'd5;  silent = 0; end // G4
        8'd13: begin note_code = 6'd8;  silent = 0; end // C5
        8'd14: begin note_code = 6'd10; silent = 0; end // E5
        8'd15: begin note_code = 6'd12; silent = 0; end // G5
        8'd16: begin note_code = 6'd7;  silent = 0; end // B4
        8'd17: begin note_code = 6'd5;  silent = 0; end // G4
        8'd18: begin note_code = 6'd3;  silent = 0; end // E4
        8'd19: begin note_code = 6'd1;  silent = 0; end // C4
        8'd20: begin note_code = 6'd5;  silent = 0; end // G4
        8'd21: begin note_code = 6'd8;  silent = 0; end // C5
        8'd22: begin note_code = 6'd7;  silent = 0; end // B4
        8'd23: begin note_code = 6'd9;  silent = 0; end // D5
        8'd24: begin note_code = 6'd12; silent = 0; end // G5
        8'd25: begin note_code = 6'd11; silent = 0; end // F5
        8'd26: begin note_code = 6'd9;  silent = 0; end // D5
        8'd27: begin note_code = 6'd7;  silent = 0; end // B4
        8'd28: begin note_code = 6'd5;  silent = 0; end // G4
        8'd29: begin note_code = 6'd7;  silent = 0; end // B4
        8'd30: begin note_code = 6'd9;  silent = 0; end // D5
        8'd31: begin note_code = 6'd11; silent = 0; end // F5
        8'd32: begin note_code = 6'd10; silent = 0; end // E5
        8'd33: begin note_code = 6'd9;  silent = 0; end // D5
        8'd34: begin note_code = 6'd7;  silent = 0; end // B4
        8'd35: begin note_code = 6'd5;  silent = 0; end // G4
        8'd36: begin note_code = 6'd4;  silent = 0; end // F4
        8'd37: begin note_code = 6'd2;  silent = 0; end // D4
        8'd38: begin note_code = 6'd5;  silent = 0; end // G4
        8'd39: begin note_code = 6'd0;  silent = 1; end // REST
        8'd40: begin note_code = 6'd8;  silent = 0; end // C5
        8'd41: begin note_code = 6'd8;  silent = 0; end // C5
        8'd42: begin note_code = 6'd9;  silent = 0; end // D5
        8'd43: begin note_code = 6'd10; silent = 0; end // E5
        8'd44: begin note_code = 6'd9;  silent = 0; end // D5
        8'd45: begin note_code = 6'd8;  silent = 0; end // C5
        8'd46: begin note_code = 6'd7;  silent = 0; end // B4
        8'd47: begin note_code = 6'd5;  silent = 0; end // G4
        8'd48: begin note_code = 6'd5;  silent = 0; end // G4
        8'd49: begin note_code = 6'd6;  silent = 0; end // A4
        8'd50: begin note_code = 6'd7;  silent = 0; end // B4
        8'd51: begin note_code = 6'd9;  silent = 0; end // D5
        8'd52: begin note_code = 6'd8;  silent = 0; end // C5
        8'd53: begin note_code = 6'd6;  silent = 0; end // A4
        8'd54: begin note_code = 6'd4;  silent = 0; end // F4
        8'd55: begin note_code = 6'd5;  silent = 0; end // G4
        8'd56: begin note_code = 6'd6;  silent = 0; end // A4
        8'd57: begin note_code = 6'd8;  silent = 0; end // C5
        8'd58: begin note_code = 6'd7;  silent = 0; end // B4
        8'd59: begin note_code = 6'd5;  silent = 0; end // G4
        8'd60: begin note_code = 6'd3;  silent = 0; end // E4
        8'd61: begin note_code = 6'd5;  silent = 0; end // G4
        8'd62: begin note_code = 6'd8;  silent = 0; end // C5
        8'd63: begin note_code = 6'd0;  silent = 1; end // REST
        default: begin note_code = 6'd0; silent = 1; end
    endcase
end

// === PWM Output ===
reg [31:0] cnt = 0;
always @(posedge clk) begin
    if (freq_div == 0) begin
        AUD_PWM <= 0;
    end else begin
        if (cnt >= freq_div) begin
            cnt <= 0;
            AUD_PWM <= ~AUD_PWM;
        end else begin
            cnt <= cnt + 1;
        end
    end
end

// === Beat Timing ===
reg [31:0] beat_cnt = 0;
always @(posedge clk) begin
    if (beat_cnt >= 12500000) begin // 0.5s at 25MHz
        beat_cnt <= 0;
        if (melody_index == 8'd63)
            melody_index <= 0;
        else
            melody_index <= melody_index + 1;
    end else begin
        beat_cnt <= beat_cnt + 1;
    end
end

endmodule

