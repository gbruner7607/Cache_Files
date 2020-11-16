
module buffer( Clk, 

                   dataIn, 

                   RD, 

                   WR, 

                   EN, 

                   dataOut, 

                   Rst,

                   EMPTY, 

                   FULL 

                   ); 

input  Clk, 

       RD, 

       WR, 

       EN, 

       Rst;

output  EMPTY, 

        FULL;

input   [31:0]    dataIn;

output reg [31:0] dataOut; // internal registers 

reg [5:0]  Count = 0; 

reg [31:0] FIFO [32]; 

reg [5:0]  readCounter = 0, 

           writeCounter = 0; 

assign EMPTY = (Count==0)? 1'b1:1'b0; 

assign FULL = (Count==32)? 1'b1:1'b0; 

//integer i;

always @ (posedge Clk) 

begin 

 if (EN==0); 

 else begin 

  if (Rst) begin 

   readCounter = 0; 

   writeCounter = 0; 
   Count <= 0;
   dataOut <= 0;
   //for (i=0; i<8; i++) begin
      //FIFO [i] = 0;
  // end

  end 

  else if (RD ==1'b1 && ~EMPTY) begin 

   dataOut <= FIFO[readCounter]; 

   readCounter = readCounter+1; 
  end 

  else if (WR==1'b1 && ~FULL) begin
   FIFO[writeCounter]  = dataIn; 

   writeCounter  = writeCounter+1; 

  end 

  else; 

 end 

 if (writeCounter>32) 

  writeCounter=0; 

 else if (readCounter>32) 

  readCounter=0; 

 else;

 if (readCounter > writeCounter) begin 

  Count=readCounter-writeCounter; 

 end 

 else if (writeCounter > readCounter) 

  Count=writeCounter-readCounter; 

 else Count = 0;

end 

endmodule
