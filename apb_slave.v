module apb_slave_asynch
#(
   parameter  unsigned APB_DATA_WIDTH = 32,
   parameter  unsigned APB_ADDR_WIDTH = 32
)
(
   input                               clk,
   input                               rst_n,

   // MASTER PORT
   output reg[APB_ADDR_WIDTH-1:0]        PADDR_o,
   output reg[APB_DATA_WIDTH-1:0]        PWDATA_o,
   output    reg                          PWRITE_o,
   output       reg                       PSEL_o,
   output       reg                       PENABLE_o,
   input  [APB_DATA_WIDTH-1:0]        PRDATA_i,
   input                               PREADY_i,
   input                               PSLVERR_i,


   // Slave ASYNCH PORT
   input                               asynch_req_i,
   output          reg                    asynch_ack_o,

   input  [APB_ADDR_WIDTH-1:0]        async_PADDR_i,
   input  [APB_DATA_WIDTH-1:0]        async_PWDATA_i,
   input                               async_PWRITE_i,
   input                               async_PSEL_i,

   output reg[APB_DATA_WIDTH-1:0]        async_PRDATA_o,
   output    reg                          async_PSLVERR_o
);

    parameter [1:0] IDLE = 2'b00, WAIT_PREADY = 2'b01, ACK_UP = 2'b10;

    reg [1:0] NS, CS;
    reg req_sync0, req_sync, sample_req, sample_resp;

    always @(posedge clk, negedge rst_n)
    begin
        if (!rst_n)
        begin
            req_sync0  <= 1'b0;
            req_sync   <= 1'b0;
            CS         <= IDLE;

            PADDR_o        <= 32'h0;
            PWDATA_o       <= 32'h0;
            PWRITE_o       <= 1'b0;
            PSEL_o         <= 1'b0;
            async_PRDATA_o <= 32'h0;
            async_PSLVERR_o<= 1'b0; 
        end
        else
        begin
            req_sync0  <= asynch_req_i;
            req_sync   <= req_sync0;
            CS         <= NS;

            if(sample_req)
            begin
              PADDR_o  <= async_PADDR_i;
              PWDATA_o <= async_PWDATA_i;
              PWRITE_o <= async_PWRITE_i;
              PSEL_o   <= async_PSEL_i;
            end

            if(sample_resp)
            begin
              async_PRDATA_o  <= PRDATA_i;
              async_PSLVERR_o <= PSLVERR_i;  
            end
        end
    end

    always @(*)
    begin
        sample_req  = 1'b0;
        sample_resp = 1'b0;

        PENABLE_o  = 1'b0;

        asynch_ack_o   = 0;    
      
        NS = CS;

        case(CS)
          IDLE: begin
              sample_req = req_sync;

              if(req_sync)
              begin
                NS = WAIT_PREADY;
              end
              else
              begin
                NS = IDLE;
              end
          end

          WAIT_PREADY:
          begin
              PENABLE_o   = 1'b1;
              sample_resp = PREADY_i; 
              if(PREADY_i)
              begin
                NS       = ACK_UP;
              end
              else
              begin
                NS = WAIT_PREADY;
              end
          end

          ACK_UP:
          begin
              asynch_ack_o  = 1'b1;
	      if(~req_sync)
            begin
              NS = IDLE;
            end
            else
            begin
              NS = ACK_UP;
            end
        end

        default:
        begin
          NS = IDLE;
        end

      endcase 

    end


endmodule
