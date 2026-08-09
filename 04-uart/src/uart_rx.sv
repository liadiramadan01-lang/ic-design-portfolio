
module uart_rx(

    input logic clk,rst,rx,
    output logic rx_done,
    output logic [7:0] rx_data

    );

    typedef enum logic[1:0] { 
        IDLE=2'b00,
        START=2'b01,
        DATA =2'b10,
        STOP=2'b11
    } state_t;

    state_t state,next_state;

    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 115_200;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; // = 434

    logic [8:0] t_cycles;
    logic [2:0] t_bits;

 always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        state    <= IDLE;
        t_cycles <= 0;
        t_bits   <= 0;
    end
    else begin
        case(state)
            IDLE:if (rx==0) begin
                    state<=next_state;
                end
            START:if (t_cycles==(CLKS_PER_BIT-1)/2) begin
                    state<=next_state;
                    t_cycles <= 0;
                end     
                else begin
                    t_cycles<=t_cycles+1;
                end
            DATA:if (t_cycles == CLKS_PER_BIT-1) begin
                    rx_data[t_bits] <=rx ;
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
        IDLE:  if(rx==0)              next_state = START;
               else                      next_state = IDLE;
        START: if(t_cycles==(CLKS_PER_BIT-1)/2) next_state = DATA;
               else                      next_state = START;
        DATA:  if(t_bits==7 && t_cycles==CLKS_PER_BIT-1) next_state = STOP;
               else                      next_state = DATA;
        STOP:  if(t_cycles==CLKS_PER_BIT-1) next_state = IDLE;
               else                      next_state = STOP;
        default: next_state = IDLE;
    endcase
end

 always_comb begin
    
    rx_done = 0;  // valeur par défaut
    case(state)
        IDLE  : begin     rx_done = 0; end
        START : begin     rx_done = 0; end
        DATA  : begin     rx_done = 0; end
        STOP  : begin     rx_done = 1; end
        default: begin    rx_done = 0; end
    endcase
 end



endmodule

