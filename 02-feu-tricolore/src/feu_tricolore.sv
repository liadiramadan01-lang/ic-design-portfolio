module feu_tricolore(
    input logic clk,
    input logic rst,
    input logic en,
    output logic red,green,orange 
);

typedef enum logic[1:0] { 
    Green=2'b00,
    Orange=2'b01,
    Red=2'b10
} state_t;

state_t state,next_state;

logic [5:0] t;
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= Green;
        t<= 0;
    end
    else if(en) begin
        case(state)
            Green:if(t == 29) begin
                    t <= 0;
                    state <= next_state;
                end
                else
                    t <= t+1;
            Orange:if(t == 4) begin
                    t <= 0;
                    state <= next_state;
                end
                else
                    t <= t+1;
            Red:if(t == 29) begin
                    t <= 0;
                    state <= next_state;
                end   
                else
                    t <= t+1; 
        endcase
        
        
    end
end

always_comb begin
    green=0;
    orange=0;
    red=0;
    case(state)
        Green:green=1;
        Orange:orange=1;
        Red:red=1;
    default: begin 
                green=0;
                orange=0; 
                red=0 ;
            end
    endcase
end

always_comb begin
    case(state)
        Green:  if(t==29) next_state = Orange;
                else      next_state = Green;
        Orange: if(t==4)  next_state = Red;
                else      next_state = Orange;
        Red:    if(t==29) next_state = Green;
                else      next_state = Red;
        default: next_state = Green;
    endcase
end
endmodule