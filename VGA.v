`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:24:23 04/23/2015 
// Design Name: 
// Module Name:    VGA 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module VGA(input clk, reset , 
	input [ 12 * 16 - 1 : 0 ] ZBCode ,
	output [ 2 : 0 ] RGB_out ,
	output VGA_HSINC, VGA_VSINC );
	
	//wire [ 2 : 0 ] RGB_out;
	reg vga_clk;
	wire valid;
	reg [ 2 : 0 ] RGB;
	reg [ 6 : 0 ] line [ 0 : 127 ] ;
	reg [ 3 : 0 ] word_cnt = 7'b0 ;
	reg [ 13 : 0 ] addr ;
	wire [ 255 : 0 ] ZiMoCode ;
	wire [ 511 : 0 ] ZiMoCode_amp ;
	
	/** MyRom is the module name of the ZiKu rom. **/
	/** The ROM is 8448 x 256 bit. One HanZi at a time **/
	MyRom R0( .a( addr ) , .spo( ZiMoCode ) ) ;
	
	ZiMoAmplify Z0( ZiMoCode , ZiMoCode_amp ) ;
	
	
	always @( posedge clk or posedge reset )
		if ( reset ) begin
			word_cnt = 1 ;
			addr <= ZBCode[ 16 * word_cnt -1 : 0 ] ;
		end
		else if ( word_cnt > 16 ) ;
		else begin
			line[ (word_cnt-1) / 4 + 1 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 479 : 448 ] ;
			line[ (word_cnt-1) / 4 + 2 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 447 : 416 ] ;
			line[ (word_cnt-1) / 4 + 3 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 415 : 384 ] ;
			line[ (word_cnt-1) / 4 + 4 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 383 : 352 ] ;
			line[ (word_cnt-1) / 4 + 5 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 351 : 320 ] ;
			line[ (word_cnt-1) / 4 + 6 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 319 : 288 ] ;
			line[ (word_cnt-1) / 4 + 7 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 287 : 256 ] ;
			line[ (word_cnt-1) / 4 + 8 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 255 : 224 ] ;
			line[ (word_cnt-1) / 4 + 9 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 223 : 192 ] ;
			line[ (word_cnt-1) / 4 + 10 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 191 : 160 ] ;
			line[ (word_cnt-1) / 4 + 11 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 159 : 128 ] ;
			line[ (word_cnt-1) / 4 + 12 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 127 : 96 ] ;
			line[ (word_cnt-1) / 4 + 13 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 95 : 64 ] ;
			line[ (word_cnt-1) / 4 + 14 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 63 : 32 ] ;
			line[ (word_cnt-1) / 4 + 15 ][ ((word_cnt-1)%4) * 32 : ((word_cnt-1)%4)*32 + 32 ] = ZiMoCode_amp[ 31 : 0 ] ;
			word_cnt = word_cnt + 1'b1 ;
		end
	// max( x_cnt ) = 800;  max( y_cnt ) = 525 //
	reg [ 9 : 0 ] x_cnt,y_cnt;
	
	//** generate vga_clk, cycle of which is 25MHz **//
	always @( * ) begin
		if ( reset ) vga_clk = 1'b0;
		else
			vga_clk = clk ;
	end
	
	assign valid = ( ( x_cnt > 10'd181 ) && ( x_cnt < 10'd987 ) ) // 800 
					&& ( ( y_cnt > 10'd27  ) && ( y_cnt < 10'd631 ) ); // 600

	assign VGA_HSINC = ( ( x_cnt > 10'd181 ) && ( x_cnt < 10'd987 ) );//*800*//
	assign VGA_VSINC = ( ( y_cnt > 10'd27  ) && ( y_cnt < 10'd631 ) );//*600*//
	
	assign RGB_out = valid ? RGB : 3'b0 ;
	
	always @( posedge vga_clk or posedge reset ) begin
		if ( reset ) x_cnt <= 1'b0 ;
		else if ( x_cnt < 1039 ) x_cnt <= x_cnt + 1'b1 ;
		else x_cnt <= 1'b0 ;
	end
	
	always @( posedge vga_clk or posedge reset ) begin
		if ( reset ) y_cnt <= 1'b0 ;
		else if ( y_cnt >= 665 ) y_cnt <= 1'b0 ;
		else if ( x_cnt == 1039 ) y_cnt <= y_cnt + 1'b1 ;
	end
	
	always @( posedge vga_clk or posedge reset ) 
		if ( reset ) RGB <= 3'b0 ;
		else begin
			case ( y_cnt )
				10'd279 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[0][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd280 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[1][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd281 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[2][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd282 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[3][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd283 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[4][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd284 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[5][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd285 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[6][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd286 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[7][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd287 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[8][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd288 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[9][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd289 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[10][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd290 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[11][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd291 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[12][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd292 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[13][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd293 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[14][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd294 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[15][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd295 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[16][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd296 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[17][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd297 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[18][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd298 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[19][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd299 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[20][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd300 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[21][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd301 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[22][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd302 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[23][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd303 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[24][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd304 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[25][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd305 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[26][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd306 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[27][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd307 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[28][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd308 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[29][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd309 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[30][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd310 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[31][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd311 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[32][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd312 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[33][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd313 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[34][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd314 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[35][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd315 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[36][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd316 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[37][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd317 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[38][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd318 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[39][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd319 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[40][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd320 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[41][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd321 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[42][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd322 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[43][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd323 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[44][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd324 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[45][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd325 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[46][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd326 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[47][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd327 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[48][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd328 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[49][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd329 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[50][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd330 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[51][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd331 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[52][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd332 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[53][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd333 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[54][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd334 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[55][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd335 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[56][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd336 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[57][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd337 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[58][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd338 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[59][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd339 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[60][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd340 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[61][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd341 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[62][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd342 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[63][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd343 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[64][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd344 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[65][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd345 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[66][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd346 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[67][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd347 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[68][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd348 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[69][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd349 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[70][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd350 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[71][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd351 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[72][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd352 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[73][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd353 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[74][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd354 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[75][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd355 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[76][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd356 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[77][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd357 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[78][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd358 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[79][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd359 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[80][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd360 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[81][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd361 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[82][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd362 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[83][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd363 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[84][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd364 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[85][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd365 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[86][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd366 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[87][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd367 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[88][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd368 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[89][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd369 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[90][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd370 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[91][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd371 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[92][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd372 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[93][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd373 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[94][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				10'd374 : if ( x_cnt >= 10'd517 && x_cnt < 10'd645 ) RGB <= line[95][ x_cnt - 10'd517 ] ; else RGB <= 3'b0 ;
				default : RGB <= 3'b0 ;
			endcase
		end
endmodule
