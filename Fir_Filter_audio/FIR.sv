

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
    24'hFFF5BC, 24'h000EEA, 24'h0006D2, 24'hFFED07, 24'hFFFDB7, 
    24'h0017C0, 24'hFFFB79, 24'hFFE368, 24'h000EC0, 24'h002019, 
    24'hFFE2EC, 24'hFFDFD5, 24'h002F68, 24'h001A4E, 24'hFFBB75, 
    24'hFFF406, 24'h005A09, 24'hFFF322, 24'hFF93CF, 24'h003142, 
    24'h007648, 24'hFF9F4A, 24'hFF8D06, 24'h0098D2, 24'h005CE4, 
    24'hFF2AF6, 24'hFFD0BE, 24'h010EA3, 24'hFFE6A7, 24'hFEC322, 
    24'h007E6C, 24'h01554E, 24'hFF00F9, 24'hFEB3D5, 24'h019793, 
    24'h011483, 24'hFDBE2A, 24'hFF603D, 24'h02F549, 24'hFFDBC3, 
    24'hFC5849, 24'h015306, 24'h044E09, 24'hFCDD67, 24'hFB22B9, 
    24'h061EA6, 24'h054B94, 24'hF3AECD, 24'hFA6EE3, 24'h285023, 
    24'h45A840, 24'h285023, 24'hFA6EE3, 24'hF3AECD, 24'h054B94, 
    24'h061EA6, 24'hFB22B9, 24'hFCDD67, 24'h044E09, 24'h015306, 
    24'hFC5849, 24'hFFDBC3, 24'h02F549, 24'hFF603D, 24'hFDBE2A, 
    24'h011483, 24'h019793, 24'hFEB3D5, 24'hFF00F9, 24'h01554E, 
    24'h007E6C, 24'hFEC322, 24'hFFE6A7, 24'h010EA3, 24'hFFD0BE, 
    24'hFF2AF6, 24'h005CE4, 24'h0098D2, 24'hFF8D06, 24'hFF9F4A, 
    24'h007648, 24'h003142, 24'hFF93CF, 24'hFFF322, 24'h005A09, 
    24'hFFF406, 24'hFFBB75, 24'h001A4E, 24'h002F68, 24'hFFDFD5, 
    24'hFFE2EC, 24'h002019, 24'h000EC0, 24'hFFE368, 24'hFFFB79, 
    24'h0017C0, 24'hFFFDB7, 24'hFFED07, 24'h0006D2, 24'h000EEA, 
    24'hFFF5BC
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