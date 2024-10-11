`timescale 1ns/1ns

module FIR_tb ();
  localparam FILE_PATH = "C:/Users/Admin/Desktop/FIR/sine.hex";
  localparam OUT_PATH  = "C:/Users/Admin/Desktop/FIR/output.txt";
  localparam FREQ = 100_000_000;

  localparam WD_IN       = 24                ; // Data width
  localparam WD_OUT      = 24                ;
  localparam PERIOD      = 1_000_000_000/FREQ;
  localparam HALF_PERIOD = PERIOD/2          ;

  // Testbench signals
  reg               clk, rst_n;
  reg  [ WD_IN-1:0] data_in ;
  wire [WD_OUT-1:0] data_out;

  integer file, status, outfile;

  real analog_in, analog_out;
  assign analog_in  = $itor($signed(data_in));
  assign analog_out = $itor($signed(data_out));

  // Instantiate the FIR filter module
  FIR dut (
    .clk     (clk     ),
    .rst_n (rst_n ),
    .data_in (data_in ),
    .data_out(data_out)
  );

  // Clock generation
  always #HALF_PERIOD clk = ~clk;

  // Test procedure
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    // Initialize inputs
    clk     = 0;
    rst_n = 0;
    data_in = 0;

    // Apply reset
    #PERIOD rst_n = 1;  // Deassert reset after a period

    // Read hex file
    file = $fopen(FILE_PATH,"r");
    outfile = $fopen(OUT_PATH, "w");
    if (file == 0)    $error("Hex file not opened");
    if (outfile == 0) $error("Output file not opened");
    do begin
      status = $fscanf(file, "%h", data_in);
      @(posedge clk);
      $fdisplay(outfile, "%h", data_out);
    end while (status != -1);

    // Wait for a while to observe output
    #100 $finish;  // Stop simulation after 100 time units
    $fclose(file);
    $fclose(outfile);
  end

  // Monitor signals for debugging
  initial begin
    $monitor(" Data Out = %h",
       data_out);
  end

endmodule
