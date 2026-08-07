
module uart_tx(
    input logic clk,rst,tx_start,
    input logic [7:0] tx_data,
    output logic tx,tx_busy
 );
 
 typedef enum logic [1:0]{
        IDLE=2'b00,
        START=2'b01,
        DATA =2'b10,
        STOP=2'b11
    }state_t;

    state_t state,next_state;



 parameter CLK_FREQ  = 50_000_000;
 parameter BAUD_RATE = 115_200;
 parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; // = 434
    

 logic [8:0] t_cycles;
 logic [2:0] t_bits;

 always_ff @(posedge clk ) begin
    if(rst) begin
        state    <= IDLE;
        t_cycles <= 0;
        t_bits   <= 0;
    end
    else begin
        case(state)
            IDLE:if (tx_start) begin
                    state<=next_state;
                end
            START:if (t_cycles==CLKS_PER_BIT-1) begin
                    state<=next_state;
                    t_cycles <= 0;
                end     
                else begin
                    t_cycles<=t_cycles+1;
                end
            DATA:if (t_cycles == CLKS_PER_BIT-1) begin
                    t_cycles <= 0;
                    if (t_bits == 7) begin
                        state  <= next_state;
                        t_bits <= 0;
                    end
                    else
                        t_bits <= t_bits + 1;
                end
                else
                    t_cycles <= t_cycles + 1;
            STOP: if (t_cycles== CLKS_PER_BIT-1) begin
                    state<=next_state;
                    t_cycles<=0;
                end
                else 
                    t_cycles<=t_cycles+1;
        endcase
    end 
 end

 always_comb begin
    case(state)
        IDLE:  if(tx_start)              next_state = START;
               else                      next_state = IDLE;
        START: if(t_cycles==CLKS_PER_BIT-1) next_state = DATA;
               else                      next_state = START;
        DATA:  if(t_bits==7 && t_cycles==CLKS_PER_BIT-1) next_state = STOP;
               else                      next_state = DATA;
        STOP:  if(t_cycles==CLKS_PER_BIT-1) next_state = IDLE;
               else                      next_state = STOP;
        default: next_state = IDLE;
    endcase
end

 always_comb begin
    tx      = 1;  // valeur par défaut — ligne IDLE
    tx_busy = 0;  // valeur par défaut
    case(state)
        IDLE  : begin tx = 1;    tx_busy = 0; end
        START : begin tx = 0;    tx_busy = 1; end
        DATA  : begin tx = tx_data[t_bits]; tx_busy = 1; end
        STOP  : begin tx = 1;    tx_busy = 1; end
        default: begin tx = 1;   tx_busy = 0; end
    endcase
 end

 


endmodule
