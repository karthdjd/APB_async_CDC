module apb_master_asynch
#(
   parameter  unsigned APB_DATA_WIDTH = 32,
   parameter  unsigned APB_ADDR_WIDTH = 32
)
(
   input                                clk,
   input                                rst_n,

   // SLAVE PORT
   input  [APB_ADDR_WIDTH-1:0]         PADDR_i,
   input  [APB_DATA_WIDTH-1:0]         PWDATA_i,
   input                                PWRITE_i,
   input                                PSEL_i,
   input                                PENABLE_i,
   output reg[APB_DATA_WIDTH-1:0]         PRDATA_o,
   output    reg                           PREADY_o,
   output       reg                        PSLVERR_o,


   // Mastwe ASYNCH PORT
   output            reg                  asynch_req_o,
   input                                asynch_ack_i,

   output reg [APB_ADDR_WIDTH-1:0]         async_PADDR_o,
   output reg[APB_DATA_WIDTH-1:0]         async_PWDATA_o,
   output    reg                           async_PWRITE_o,
   output       reg                        async_PSEL_o,

   input  [APB_DATA_WIDTH-1:0]         async_PRDATA_i,
   input                                async_PSLVERR_i
);


    parameter [1:0] IDLE = 2'b00, REQ_UP = 2'b01, REQ_DOWN = 2'b10;
    reg [1:0] NS, CS;
    reg ack_sync0, ack_sync;

    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            ack_sync0  <= 1'b0;
            ack_sync   <= 1'b0;
            CS         <= IDLE;
        end
        else
        begin
            ack_sync0  <= asynch_ack_i;
            ack_sync   <= ack_sync0;
            CS         <= NS;
        end
    end


    always @*
    begin
      NS = CS;

      asynch_req_o   = 1'b0;
      PRDATA_o       = async_PRDATA_i;
      PREADY_o       = 1'b0;
      PSLVERR_o      = async_PSLVERR_i;      
      async_PADDR_o  = PADDR_i;
      async_PWDATA_o = PWDATA_i;
      async_PWRITE_o = PWRITE_i;
      async_PSEL_o   = PSEL_i;

      case(CS)
        IDLE: begin
            if(PSEL_i & PENABLE_i)
            begin
              NS = REQ_UP;
            end
            else
            begin
              NS = IDLE;
            end
        end

        REQ_UP:
        begin
            asynch_req_o = 1'b1;
            if(ack_sync)
            begin
              NS       = REQ_DOWN;
              PREADY_o  = 1'b1;
            end
            else
            begin
               NS = REQ_UP;
            end
        end

        REQ_DOWN:
        begin
            asynch_req_o  = 1'b0;
            if(~ack_sync)
            begin
              NS = IDLE;
            end
            else
            begin
              NS = REQ_DOWN;
            end
        end

        default:
        begin
          NS = IDLE;
        end
      endcase // CS

    end

endmodule
