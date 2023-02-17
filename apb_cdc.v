module apb_cdc #(
   parameter APB_DATA_WIDTH = 32,
   parameter APB_ADDR_WIDTH = 32)(

   input                              src_clk,
   input                              src_rst_n,

   // SLAVE PORT
   input  [APB_ADDR_WIDTH-1:0]        src_PADDR_i,
   input  [APB_DATA_WIDTH-1:0]        src_PWDATA_i,
   input                               src_PWRITE_i,
   input                               src_PSEL_i,
   input                               src_PENABLE_i,
   output [APB_DATA_WIDTH-1:0]        src_PRDATA_o,
   output                              src_PREADY_o,
   output                              src_PSLVERR_o,

   input                              dest_clk,
   input                              dest_rst_n,
   output [APB_ADDR_WIDTH-1:0]        dest_PADDR_o,
   output [APB_DATA_WIDTH-1:0]        dest_PWDATA_o,
   output                              dest_PWRITE_o,
   output                              dest_PSEL_o,
   output                              dest_PENABLE_o,
   input  [APB_DATA_WIDTH-1:0]        dest_PRDATA_i,
   input                               dest_PREADY_i,
   input                               dest_PSLVERR_i
);

   wire                              asynch_req;
   wire                              asynch_ack;
   wire [APB_ADDR_WIDTH-1:0]        async_PADDR;
   wire [APB_DATA_WIDTH-1:0]        async_PWDATA;
   wire                              async_PWRITE;
   wire                              async_PSEL;
   wire [APB_DATA_WIDTH-1:0]        async_PRDATA;
   wire                              async_PSLVERR;


  apb_master_asynch
  #(
     .APB_DATA_WIDTH ( APB_DATA_WIDTH ),
     .APB_ADDR_WIDTH ( APB_ADDR_WIDTH )
  )
  i_apb_master_asynch
  (
     .clk             ( src_clk        ),
     .rst_n           ( src_rst_n      ),

     // SLAVE SYNCH PORT
     .PADDR_i         ( src_PADDR_i    ),
     .PWDATA_i        ( src_PWDATA_i   ),
     .PWRITE_i        ( src_PWRITE_i   ),
     .PSEL_i          ( src_PSEL_i     ),
     .PENABLE_i       ( src_PENABLE_i  ),
     .PRDATA_o        ( src_PRDATA_o   ),
     .PREADY_o        ( src_PREADY_o   ),
     .PSLVERR_o       ( src_PSLVERR_o  ),


     // MASTER ASYNCH PORT
     .asynch_req_o    ( asynch_req     ),
     .asynch_ack_i    ( asynch_ack     ),
     .async_PADDR_o   ( async_PADDR    ),
     .async_PWDATA_o  ( async_PWDATA   ),
     .async_PWRITE_o  ( async_PWRITE   ),
     .async_PSEL_o    ( async_PSEL     ),
     .async_PRDATA_i  ( async_PRDATA   ),
     .async_PSLVERR_i ( async_PSLVERR  )
  );


  apb_slave_asynch
  #(
     .APB_DATA_WIDTH  ( APB_DATA_WIDTH ),
     .APB_ADDR_WIDTH  ( APB_ADDR_WIDTH )
  )
  i_apb_slave_asynch
  (
     .clk             ( dest_clk        ),
     .rst_n           ( dest_rst_n      ),

     .PADDR_o         ( dest_PADDR_o    ),
     .PWDATA_o        ( dest_PWDATA_o   ),
      .PWRITE_o        ( dest_PWRITE_o   ),
     .PSEL_o          ( dest_PSEL_o     ),
     .PENABLE_o       ( dest_PENABLE_o  ),
     .PRDATA_i        ( dest_PRDATA_i   ),
     .PREADY_i        ( dest_PREADY_i   ),
     .PSLVERR_i       ( dest_PSLVERR_i  ),

     .asynch_req_i    ( asynch_req      ),
     .asynch_ack_o    ( asynch_ack      ),
     .async_PADDR_i   ( async_PADDR     ),
     .async_PWDATA_i  ( async_PWDATA    ),
     .async_PWRITE_i  ( async_PWRITE    ),
     .async_PSEL_i    ( async_PSEL      ),
     .async_PRDATA_o  ( async_PRDATA    ),
     .async_PSLVERR_o ( async_PSLVERR   )
  );

endmodule 
