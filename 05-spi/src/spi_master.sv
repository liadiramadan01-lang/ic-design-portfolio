
module spi_master(

    input logic clk,rst,start,miso,
    input logic [7:0] mosi_data,
    output logic sclk,cs,mosi,done,
    output logic [7:0] miso_data

    ); 

    typedef enum logic[1:0] { 
        IDLE=2'b00,
        TRANSFER=2'b01,
        DONE=2'b10
    } state_t;

    state_t state,next_state;

    parameter CLKS_PER_HALF_BIT = 25;

    logic [2:0] t_bits;
    logic [4:0] t_cycles;
    logic sclk_phase;

    always_ff @(posedge clk or posedge rst) begin 

        if (rst)begin 
            state<=IDLE;
            t_bits<=0;
            t_cycles<=0;
            sclk_phase <= 0;
            sclk <= 0;
            mosi <= 0;

        end
        else begin 
            case(state)
                IDLE:if(start==1)begin
                        mosi <= 0;
                        state<=next_state;
                 end
                TRANSFER:if(t_cycles == CLKS_PER_HALF_BIT-1) begin
                            t_cycles <= 0;
                            sclk_phase <= ~sclk_phase;  // alterne entre 0 et 1

                            if(sclk_phase == 0) begin
                            // fin de la première demi-période — SCLK monte
                                sclk <= 1;
                                miso_data[7-t_bits] <= miso;  // on lit MISO au milieu
                            end
                            else begin
                            // fin de la deuxième demi-période — SCLK descend
                                sclk <= 0;
                                mosi <= mosi_data[7-t_bits];  // on envoie le prochain bit
                                if(t_bits == 7) begin
                                    state  <= next_state;
                                    t_bits <= 0;
                                end
                                else
                                    t_bits <= t_bits + 1;
                            end
                        end
                        else
                            t_cycles <= t_cycles + 1;
                
                DONE:if(t_cycles==CLKS_PER_HALF_BIT-1) begin 
                        t_cycles<=0;
                        state<=next_state;
                       
                    end
                    else t_cycles<=t_cycles+1;

            endcase
        end
    end



    always_comb begin 
    case (state)
        IDLE:     if(start==1)                                          next_state = TRANSFER;
                  else                                                   next_state = IDLE;
        TRANSFER: if(t_bits==7 && t_cycles==CLKS_PER_HALF_BIT-1 && sclk_phase==1) next_state = DONE;
                  else                                                   next_state = TRANSFER;
        DONE:     if(t_cycles==CLKS_PER_HALF_BIT-1)                    next_state = IDLE;
                  else                                                   next_state = DONE;
        default:  next_state = IDLE;
    endcase
    end
    
    always_comb begin 
        done=0;
        cs=1;
        case (state)
                IDLE: begin cs=1; done=0; end
                TRANSFER:begin cs=0; done=0; end
                DONE: begin cs=0; done=1; end 
                default: begin cs=1; done=0; end
        endcase
    end 

endmodule

