module apb_cdc_tb;
  reg                              src_clk;
  reg                              src_rst_n;

   // SLAVE PORT
   reg     [31:0]        src_PADDR_i;
   reg [31:0]        src_PWDATA_i;
   reg                             src_PWRITE_i;
   reg                             src_PSEL_i;
   reg                           src_PENABLE_i;
   wire [31:0]        src_PRDATA_o;
   wire                            src_PREADY_o;
   wire                           src_PSLVERR_o;

   reg                              dest_clk;
   reg                             dest_rst_n;
   wire [31:0]        dest_PADDR_o;
   wire [31:0]        dest_PWDATA_o;
   wire                            dest_PWRITE_o;
   wire                             dest_PSEL_o;
   wire                             dest_PENABLE_o;
   reg  [31:0]        dest_PRDATA_i;
   reg                             dest_PREADY_i;
   reg                           dest_PSLVERR_i;

   apb_cdc dut(.src_clk(src_clk),.src_rst_n(src_rst_n),.src_PADDR_i(src_PADDR_i),.src_PWDATA_i(src_PWDATA_i),.src_PWRITE_i(src_PWRITE_i),.src_PSEL_i(src_PSEL_i),.src_PENABLE_i(src_PENABLE_i),.src_PRDATA_o(src_PRDATA_o),.src_PREADY_o(src_PREADY_o),.src_PSLVERR_o(src_PSLVERR_o),.dest_clk(dest_clk),.dest_rst_n(dest_rst_n),.dest_PADDR_o(dest_PADDR_o),.dest_PWDATA_o(dest_PWDATA_o),.dest_PWRITE_o(dest_PWRITE_o),.dest_PSEL_o(dest_PSEL_o),.dest_PENABLE_o(dest_PENABLE_o),.dest_PRDATA_i(dest_PRDATA_i),.dest_PREADY_i(dest_PREADY_i),.dest_PSLVERR_i(dest_PSLVERR_i));

   initial begin
	   $dumpfile("apb_cdc.vcd");
	   $dumpvars;
	   src_clk=0;
	   src_rst_n=0;
	   dest_clk=0;
	   dest_rst_n=0;
	   #5 src_rst_n=1;
   #8 dest_rst_n=1;
   end
   always #5 src_clk=~src_clk;            always #7 dest_clk=~dest_clk;

   // source signals input
   task source();
	   begin
		   @(posedge src_clk);
		   src_PADDR_i=$random;
		   src_PWDATA_i=$random;
		   src_PWRITE_i=1;
		   src_PSEL_i=1;
		   src_PENABLE_i=1;
		   #5;
		   @(posedge src_clk);
		   src_PWRITE_i=0;
		   src_PSEL_i=0;
		   src_PENABLE_i=0;
	   end
   endtask
   task dest();
	   begin
		   @(posedge dest_clk);
		   dest_PRDATA_i=$random;
		   dest_PREADY_i=1;
		   dest_PSLVERR_i=1;
		   #5;
		   @(posedge dest_clk);
		   dest_PREADY_i=0;
                   dest_PSLVERR_i=0;
	   end
   endtask
   initial begin


   repeat(4) begin
   source();
   end
   #20;
   repeat(4) begin
	   dest();
   end
   #100 $finish;
   end
   endmodule
