/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
//---------------------------------------------------------
//-- File generated by RobustVerilog parser
//-- Version: 1.0
//-- Invoked Fri Mar 25 23:34:50 2011
//--
//-- Source file: prgen_scatter.v
//---------------------------------------------------------



module prgen_scatter8_1(ch_x,x);

   parameter                  CH_NUM     = 0;
   
   
   input [8*1-1:0]    ch_x;
   output [8-1:0]         x;


   assign               x = {
                  ch_x[CH_NUM+7],
                  ch_x[CH_NUM+6],
                  ch_x[CH_NUM+5],
                  ch_x[CH_NUM+4],
                  ch_x[CH_NUM+3],
                  ch_x[CH_NUM+2],
                  ch_x[CH_NUM+1],
                  ch_x[CH_NUM+0]};

   
endmodule
   

