//========================================================================
// proc-isa-sim +prog-num=0 +in0-switches=00000 +in1-switches=00000
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024

`define CYCLE_TIME 10

`include "ece2300/ece2300-misc.v"
`include "lab4/tinyrv1.v"
`include "lab4/test/ProcFL.v"

module Top();

  //----------------------------------------------------------------------
  // Clock/Reset
  //----------------------------------------------------------------------

  // verilator lint_off BLKSEQ
  logic clk;
  initial clk = 1'b1;
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  logic rst;

  //----------------------------------------------------------------------
  // Instantiate modules
  //----------------------------------------------------------------------

  // Processor

  logic [31:0] in0;
  logic [31:0] in1;
  logic [31:0] in2;
  logic [31:0] in3;

  logic [31:0] out0;
  logic [31:0] out1;
  logic [31:0] out2;
  logic [31:0] out3;

  logic        trace_val;
  logic [31:0] trace_addr;
  logic [31:0] trace_inst;
  logic        trace_wen;
  logic [4:0]  trace_wreg;
  logic [31:0] trace_wdata;

  ProcFL proc(.*);

  `ECE2300_UNDRIVEN( in0 );
  `ECE2300_UNDRIVEN( in1 );
  `ECE2300_UNDRIVEN( in2 );
  `ECE2300_UNDRIVEN( in3 );

  `ECE2300_UNUSED( out0 );
  `ECE2300_UNUSED( out1 );
  `ECE2300_UNUSED( out2 );
  `ECE2300_UNUSED( out3 );

  `ECE2300_UNUSED( trace_val );

  //----------------------------------------------------------------------
  // asm
  //----------------------------------------------------------------------

  TinyRV1 tinyrv1();

  logic dump_bin;

  task asm
  (
    input [31:0] addr,
    input string str
  );
    proc.M[addr] = tinyrv1.asm( addr, str );

    if ( dump_bin ) begin
      $display( "      mem[%4d] <= 32'h%x; // %x %s",
                addr/4, proc.M[addr], addr, str );
    end

  endtask

  //----------------------------------------------------------------------
  // data
  //----------------------------------------------------------------------

  logic [31:0] data_addr_unused;

  task data
  (
    input [31:0] addr,
    input [31:0] data_
  );
    proc.M[addr] = data_;
    data_addr_unused = addr;
    if ( dump_bin ) begin
      $display( "      mem[%4d] <= 32'h%x; // %x data",
                addr/4, data_, addr );
    end
  endtask

  //----------------------------------------------------------------------
  // Perform the simulation
  //----------------------------------------------------------------------

  logic step;
  logic tui;
  int c;
  int cycles = 0;
  int cycle_count = 0;
  string vcd_filename;
  string bin_filename;

  initial begin

    // Process command line arguments

    dump_bin = 0;
    if ( $test$plusargs( "dump-bin" ) )
      dump_bin = 1;

    step = 0;
    if ( $test$plusargs( "step" ) )
      step = 1;

    tui = 0;
    if ( $test$plusargs( "tui" ) )
      tui = 1;

    if ( $value$plusargs( "dump-vcd=%s", vcd_filename ) ) begin
      $dumpfile(vcd_filename);
      $dumpvars();
    end

    if ( !$value$plusargs( "bin=%s", bin_filename ) ) begin
      $display("");
      $display(" ERROR: Must specify binary file with +bin=filename");
      $display("");
      $finish;
    end

    $readmemb( bin_filename, proc.M );

    #1;

    // Reset sequence

    rst = 1;
    #(3*`CYCLE_TIME);
    rst = 0;

    // Simulate 500 cycles

    if ( step ) begin
      $display("Press enter to execute next instruction.");
      $display("Enter r then press enter to finish the program without stepping.");
      $display("Enter q then press enter to quit.\n");
      $display("cycle pc         inst                 wreg wdata      ");
      $display("------------------------------------------------------");
    end

    if ( tui ) begin
      $display("Press enter to execute next instruction.");
      $display("Enter r then press enter to finish the program without stepping.");
      $display("Enter q then press enter to quit.\n");
    end

    for ( int i = 0; i < 500; i++ ) begin

      if ( out1 == 0 )
        cycle_count = cycle_count + 1;

      if ( tui ) begin

        for ( int i = 0; i < 35; i++ ) begin

          // left column

          if ( i <= 15 ) begin
            if ( proc.pc == i*4 )
              $write( " > " );
            else
              $write( "   " );
            $write( "%-s ", tinyrv1.disasm( i*4, proc.M[i] ) );
          end
          else if ( i == 16 )
            $write( "                          " );
          else if ( i == 17 )
            $write( "      Prog Counter        " );
          else if ( i == 18 )
            $write( "     .------------.       " );
          else if ( i == 19 )
            $write( "     | 0x%x |       ", proc.pc );
          else if ( i == 20 )
            $write( "     '------------'       " );
          else if ( i == 21 )
            $write( "                          " );
          else if ( i == 22 )
            $write( "       Registers          " );
          else if ( i == 23 )
            $write( "     .------------.       " );
          else if ( i == 24 )
            $write( " x31 | 0x%x |       ", proc.R[31] );
          else if ( i == 25 )
            $write( " ... |    ....    |       " );
          else if ( i == 26 )
            $write( "  x7 | 0x%x |       ", proc.R[7] );
          else if ( i == 27 )
            $write( "  x6 | 0x%x |       ", proc.R[6] );
          else if ( i == 28 )
            $write( "  x5 | 0x%x |       ", proc.R[5] );
          else if ( i == 29 )
            $write( "  x4 | 0x%x |       ", proc.R[4] );
          else if ( i == 30 )
            $write( "  x3 | 0x%x |       ", proc.R[3] );
          else if ( i == 31 )
            $write( "  x2 | 0x%x |       ", proc.R[2] );
          else if ( i == 32 )
            $write( "  x1 | 0x%x |       ", proc.R[1] );
          else if ( i == 33 )
            $write( "  x0 | 0x%x |       ", proc.R[0] );
          else if ( i == 34 )
            $write( "     '------------'       " );

          // right column

          if ( i == 0 )
            $write("          Memory  ");
          else if ( i == 1 )
            $write("      .------------.");
          else if ( i == 2 )
            $write("0x1fc | 0x%x |", proc.M[127] );
          else if ( i == 3 )
            $write("...   |    ....    |");
          else if ( i <= 16 )
            $write("0x%x | 0x%x |", 12'('h130-(i-4)*4), proc.M[('h130-(i-4)*4)>>2] );
          else if ( i == 17 )
            $write("..    |    ....    |");
          else if ( i <= 33 )
            $write("0x%x | 0x%x |", 12'('h3c-(i-18)*4), proc.M[('h3c-(i-18)*4)>>2] );
          else if ( i == 34 )
            $write("      '------------'");

          $write("\n");

        end

        cycles = cycles + 1;

        c = $fgetc( 'h8000_0000 );
        if ( c == "q" )
          $finish;
        if ( c == "r" )
          tui = 0;

        for ( int i = 0; i < 36; i++ ) begin
          $write("\x1b[A");
        end

      end

      #`CYCLE_TIME;

      if ( step ) begin
        $write( "%4d: 0x%x %-s ", cycles, trace_addr,
                tinyrv1.disasm(trace_addr,trace_inst) );

        if ( trace_wen )
          $write( "%d 0x%x  ", trace_wreg, trace_wdata );
        else
          $write( "               " );

        cycles = cycles + 1;

        c = $fgetc( 'h8000_0000 );
        if ( c == "q" )
          $finish;
        if ( c == "r" )
          step = 0;
      end

    end

    // Finish

    $display( "cycle_count = %-0d", cycle_count );
    $finish;

  end

endmodule
