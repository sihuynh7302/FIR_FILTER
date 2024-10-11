
module FIR (
    input logic clk,                       // Clock input
    input logic rst_n,                     // Reset (active low)
    input logic signed [23:0] data_in,     // 24-bit input data
    output logic signed [23:0] data_out    // 24-bit output data
);
    // Parameter to define the filter order
    localparam ORDER = 100;

    // Filter coefficients (24-bit hex values)
    logic signed [23:0] coeffs[0:100] = '{
    24'h00000, 24'h00148, 24'h002B3, 24'h00457, 24'h0064F, 
    24'h008B2, 24'h00B9C, 24'h00F24, 24'h01366, 24'h0187A, 
    24'h01E79, 24'h02578, 24'h02D8D, 24'h036CA, 24'h04141, 
    24'h04CFE, 24'h05A0C, 24'h06873, 24'h07837, 24'h08957, 
    24'h09BD1, 24'h0AF9C, 24'h0C4AE, 24'h0DAF6, 24'h0F261, 
    24'h10AD9, 24'h12441, 24'h13E7C, 24'h15968, 24'h174E1, 
    24'h190BD, 24'h1ACD4, 24'h1C8FA, 24'h1E501, 24'h200BA, 
    24'h21BF6, 24'h23685, 24'h25038, 24'h268E0, 24'h28050, 
    24'h2965B, 24'h2AAD7, 24'h2BD9E, 24'h2CE8A, 24'h2DD7C, 
    24'h2EA54, 24'h2F4FA, 24'h2FD59, 24'h30360, 24'h30702, 
    24'h30839, 24'h30702, 24'h30360, 24'h2FD59, 24'h2F4FA, 
    24'h2EA54, 24'h2DD7C, 24'h2CE8A, 24'h2BD9E, 24'h2AAD7, 
    24'h2965B, 24'h28050, 24'h268E0, 24'h25038, 24'h23685, 
    24'h21BF6, 24'h200BA, 24'h1E501, 24'h1C8FA, 24'h1ACD4, 
    24'h190BD, 24'h174E1, 24'h15968, 24'h13E7C, 24'h12441, 
    24'h10AD9, 24'h0F261, 24'h0DAF6, 24'h0C4AE, 24'h0AF9C, 
    24'h09BD1, 24'h08957, 24'h07837, 24'h06873, 24'h05A0C, 
    24'h04CFE, 24'h04141, 24'h036CA, 24'h02D8D, 24'h02578, 
    24'h01E79, 24'h0187A, 24'h01366, 24'h00F24, 24'h00B9C, 
    24'h008B2, 24'h0064F, 24'h00457, 24'h002B3, 24'h00148, 
    24'h00000
};

    // Shift register to store previous input values
    logic signed [23:0] shift_reg[0:ORDER];

    // Accumulator for the convolution result
    logic signed [47:0] accumulator;

    // Output data (scaled back to 24-bit)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset shift register and output
            data_out <= 24'd0;
            accumulator <= 48'd0;
            for (int i = 0; i <= ORDER; i++) begin
                shift_reg[i] <= 24'd0;
            end
        end else begin
            // Shift the input data into the shift register
            for (int i = ORDER; i > 0; i--) begin
                shift_reg[i] <= shift_reg[i-1];
            end
            shift_reg[0] <= data_in;

            // Reset accumulator
            accumulator = 48'd0;

            // Perform the convolution
            for (int i = 0; i <= ORDER; i++) begin
                accumulator += shift_reg[i] * coeffs[i];
            end

            // Assign the scaled result to the output (right shift to scale down)
            data_out <= accumulator[47:24];  // Scaling by truncating lower bits
        end
    end
endmodule