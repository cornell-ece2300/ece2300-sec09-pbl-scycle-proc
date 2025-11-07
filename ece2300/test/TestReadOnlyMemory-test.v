//========================================================================
// TestReadOnlyMemory-test.v
//========================================================================

`include "ece2300/ece2300-test.v"
`include "ece2300/ece2300-misc.v"
`include "ece2300/TestReadOnlyMemory.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        mem_val;
  logic [15:0] mem_addr;
  logic [31:0] mem_rdata;

  TestReadOnlyMemory mem
  (
    .mem_val   (mem_val),
    .mem_addr  (mem_addr),
    .mem_rdata (mem_rdata)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic        mem_val_,
    input logic [15:0] mem_addr_,
    input logic [31:0] mem_rdata_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      mem_val  = mem_val_;
      mem_addr = mem_addr_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %h > %h", t.cycles, mem_val, mem_addr, mem_rdata );

      `ECE2300_CHECK_EQ( mem_rdata, mem_rdata_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //        addr      data
    mem.init( 16'h0000, 32'h0000_0003 );
    mem.init( 16'h0004, 32'h0000_0001 );

    //     val addr      rdata
    check( 0,  16'h0000, 32'hxxxx_xxxx );
    check( 1,  16'h0000, 32'h0000_0003 );
    check( 1,  16'h0004, 32'h0000_0001 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();

    t.test_bench_end();
  end

endmodule

