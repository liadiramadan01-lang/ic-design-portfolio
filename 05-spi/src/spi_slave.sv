module spi_slave(

    input logic [7:0]tx_data,
    input logic  cs, sclk, mosi,
    output logic miso, rx_done,
    output logic [7:0] rx_data

    ); 

    
    logic [2:0] t_bits;

    always_ff @(posedge sclk or posedge cs) begin
        if(cs) begin 
            t_bits  <= 0;
            rx_done <= 0;
        end
        else begin
            // échantillonner MOSI — MSB first
            rx_data <= {rx_data[6:0], mosi};
            t_bits  <= t_bits + 1;
            if(t_bits == 7)
                rx_done <= 1;
            else
                rx_done <= 0;
        end
    end

    assign miso = (!cs) ? tx_data[7-t_bits] : 1'bz;




endmodule
