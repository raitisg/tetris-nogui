PROGRAM tetris;
USES Crt, Dos; { Dos for the GetTime }
CONST pieces : Array[0..6] Of String = ('00001111', '10001110', '00010111', '01100110', '00110110', '01001110', '11000110');
			SIMB = '#';
			W = 20;
			H = 20;
VAR px, py, pr, x, y, points : Integer;
		field : Array[1..W, 1..H] Of Integer;
		piece : Array[1..4, 1..2] Of Boolean;
		startnew, cancel : Boolean;
		rnd, color : Integer;
		ch : char;

		wtmp, old_ms, new_ms : Word;
		total_ms, time_ms : Longint;
		continue : Boolean;
		
{ _Draw_ border around field, leaving everything else
	empty (border is actually inside the field) }
Procedure InitField;
Var x, y : Integer;
Begin

	For x := 1 To W Do Begin
		field[x][1] := 7;
		field[x][H] := 7;
	End;

	For y := 2 To H - 1 Do Begin
		field[1][y] := 7;
		field[W][y] := 7;
	End;
	
	For y := 2 To H - 1 Do Begin
		For x := 2 To W - 1 Do Begin
			field[x][y] := 0;
		End;
	End;
		
End;

{	Redraw playing field (without _piece_). If space is empty
	write _space_ instead of black # }
Procedure RedrawField;
Var x, y : Integer;
Begin
	
	For y := 1 To H Do Begin
		For x := 1 To W Do Begin
	
			GotoXY(x, y);

			If (field[x][y] = 0) Then
				Write(' ')
			Else Begin
				TextColor(field[x][y]);
				Write(SIMB);				
			End;
			
		End;
	End;
	
	GotoXY((W - 8) Div 2 + 1, 1);
	
	If (points < 10) Then
		Write(' 00000',points,' ')
	Else
	If (points < 100) Then
		Write(' 0000',points,' ')
	Else
	If (points < 1000) Then
		Write(' 000',points,' ')
	Else
	If (points < 10000) Then
		Write(' 00',points,' ')
	Else
	If (points < 100000) Then
		Write(' 0',points,' ')
	Else
		Write(' ',points,' ');
		
	TextColor(15);
End;

{ ---------------------------------- }

Procedure LoadPiece(piece_id : Integer);
Var x, y, n : Integer;
Begin

	For n := 1 To 8 Do Begin
		x := n;
		y := 1;
				
		If (n > 4) Then Begin
			x := n - 4;
			y := 2;
		End;
		
		If (Copy(pieces[piece_id], n, 1) = '0') Then
			piece[x][y] := False
		Else
			piece[x][y] := True;
	End;
End;

{ ---------------------------------- }

Function NewPr() : Integer;
Begin
	If (pr = 3) Then
		NewPr := 0
	Else
		NewPr := pr + 1;
End;

{ ---------------------------------- }

Procedure DrawPiece(_px, _py, _pr, color : Integer; ch_piece : Char);
Var x, y, tmpx, tmpy : Integer;
Begin

	tmpx := 0;
	tmpy := 0;
	
	TextColor(color);	
	
	GotoXY(_px, _py);

	If (_pr = 0) Then Begin
		For y := 1 To 2 Do Begin
		 	For x := 1 To 4 Do Begin

		 		If (piece[x][y] = True) Then Begin
		 			GotoXY(_px + x - 1, _py + y - 1);
		 			Write(ch_piece);
		 		End;

			End;
		End;
	End;
	
	If (_pr = 1) Then Begin
		tmpx := 1;
		For y := 1 To 2 Do Begin
			tmpy := 0;
		 	For x := 1 To 4 Do Begin

			 	If (piece[x][y] = True) Then Begin
					GotoXY(_px + tmpx + 1, _py + tmpy - 1);
			 		Write(ch_piece);
			 	End;

		 		Inc(tmpy);
			End;
			Dec(tmpx);
		End;
	End;

	If (_pr = 2) Then Begin
		tmpy := 1; 
		For y := 1 To 2 Do Begin
			tmpx := 3;
		 	For x := 1 To 4 Do Begin
		 		
		 		If (piece[x][y] = True) Then Begin
					GotoXY(_px + tmpx, _py + tmpy);
					Write(ch_piece);
				End;
		 		
		 		Dec(tmpx);
			End;
			Dec(tmpy);
		End;
	End;

	If (_pr = 3) Then Begin
		For y := 1 To 2 Do Begin
			tmpy := 3;
		 	For x := 1 To 4 Do Begin
		 	
		 		If (piece[x][y] = True) Then Begin
					GotoXY(_px + tmpx + 1, _py + tmpy - 1);
					Write(ch_piece);
				End;
		 		
		 		Dec(tmpy);
			End;
			Inc(tmpx);
		End;
	End;
	
	GotoXY(1, H + 1);

End;

{ ---------------------------------- }

Function IsMoveAllowed(_px, _py, _pr : Integer) : Boolean;
Var tmpx, tmpy, x, y : Integer;
Var ret : Boolean;
Begin

	ret := True;

	tmpx := 0;
	tmpy := 0;

	If (_pr = 0) Then Begin
		For y := 1 To 2 Do Begin
		 	For x := 1 To 4 Do Begin
		 		
		 		If (piece[x][y] = True) Then
		 			If (field[_px + x - 1][_py + y - 1] > 0) Then
		 				ret := False
		 			Else
		 				If ((_px + x - 1 < 0) Or (_py + y - 1 < 0) Or (_px + x - 1 > W) Or (_py + y - 1 > H)) Then ret := False;

			End;
		End;
	End;
	
	If (_pr = 1) Then Begin
		tmpx := 1;
		For y := 1 To 2 Do Begin
			tmpy := 0;
		 	For x := 1 To 4 Do Begin
		 	
		 		If (piece[x][y] = True) Then
		 			If (field[_px + tmpx + 1][_py + tmpy - 1] > 0) Then
		 				ret := False
		 			Else
		 				If ((_px + tmpx + 1 < 1) Or (_py + tmpy - 1 < 1) Or (_px + tmpx + 1 > W) Or (_py + tmpy - 1 > H)) Then ret := False;
		 		
		 		Inc(tmpy);
			End;
			Dec(tmpx);
		End;
	End;

	If (_pr = 2) Then Begin
		tmpy := 1; 
		For y := 1 To 2 Do Begin
			tmpx := 3;
		 	For x := 1 To 4 Do Begin
		 	
		 		If (piece[x][y] = True) Then
		 			If (field[_px + tmpx][_py + tmpy] > 0) Then
		 				ret := False
		 			Else
			 			If ((_px + tmpx < 1) Or (_py + tmpy < 1) Or (_px + tmpx > W) Or (_py + tmpy > H)) Then ret := False;

		 		Dec(tmpx);
			End;
			Dec(tmpy);
		End;
	End;

	If (_pr = 3) Then Begin
		For y := 1 To 2 Do Begin
			tmpy := 3;
		 	For x := 1 To 4 Do Begin
		 	
		 		If (piece[x][y] = True) Then
		 			If (field[_px + tmpx + 1][_py + tmpy - 1] > 0) Then
		 				ret := False
		 			Else
		 				If ((_px + tmpx + 1 < 1) Or (_py + tmpy - 1 < 1) Or (_px + tmpx + 1 > W) Or (_py + tmpy - 1 > H)) Then ret := False;

		 		Dec(tmpy);
			End;
			Inc(tmpx);
		End;
	End;
	
	IsMoveAllowed := ret;
End;


{ ---------------------------------- }

Procedure SaveCurrentPiece();
Var x, y, tmpx, tmpy : Integer;
Begin

	tmpx := 0;
	tmpy := 0;
	
	If (pr = 0) Then Begin
		For y := 1 To 2 Do Begin
		 	For x := 1 To 4 Do Begin

		 		If (piece[x][y] = True) Then Begin
		 			field[px + x - 1][py + y - 1] := color;
		 		End;

			End;
		End;
	End;
	
	If (pr = 1) Then Begin
		tmpx := 1;
		For y := 1 To 2 Do Begin
			tmpy := 0;
		 	For x := 1 To 4 Do Begin

			 	If (piece[x][y] = True) Then Begin
					field[px + tmpx + 1][py + tmpy - 1] := color;
			 	End;

		 		Inc(tmpy);
			End;
			Dec(tmpx);
		End;
	End;

	If (pr = 2) Then Begin
		tmpy := 1; 
		For y := 1 To 2 Do Begin
			tmpx := 3;
		 	For x := 1 To 4 Do Begin
		 		
		 		If (piece[x][y] = True) Then Begin
					field[px + tmpx][py + tmpy] := color;
				End;
		 		
		 		Dec(tmpx);
			End;
			Dec(tmpy);
		End;
	End;

	If (pr = 3) Then Begin
		For y := 1 To 2 Do Begin
			tmpy := 3;
		 	For x := 1 To 4 Do Begin
		 	
		 		If (piece[x][y] = True) Then Begin
					field[px + tmpx + 1][py + tmpy - 1] := color;
				End;
		 		
		 		Dec(tmpy);
			End;
			Inc(tmpx);
		End;
	End;

End;

{ ---------------------------------- }

Procedure RemoveLine(line : Integer);
Begin
	For x := 2 To W - 1 Do Begin
		field[x, line] := 0;
		
		Delay(50);
		GotoXY(x, line);
		Write(' ');
	End;

	{RedrawField;}
End;

{ ---------------------------------- }

Procedure CheckForFullLines;
Var full : Boolean;
		tmpx, tmpy : Integer; 
Begin

	For y := H - 1 DownTo 2 Do Begin

		full := True;

		For x := 2 To W - 1 Do Begin
			If (field[x][y] = 0) Then full := False;
		End;

		If (full = True) Then Begin
			RemoveLine(y);

			points := points + 10;
			
			{ increase speed }
			If ((points Mod 100 = 0) And (time_ms > 5)) Then
				Dec(time_ms);

			For tmpy := y - 1 DownTo 2 Do Begin
				For tmpx := 2 To W - 1 Do Begin
					field[tmpx][tmpy + 1] := field[tmpx][tmpy];
				End;
			End;
			
			RedrawField;

			CheckForFullLines;
		End;
	End;

End;

{ ---------------------------------- }

BEGIN

	ClrScr;

	Randomize;

	points := 0;
	
	time_ms := 50; { falling delay }

	InitField;

	RedrawField;
	
	startnew := True;
	
	cancel := False;

	Repeat
		
		{ init new piece }
		
		If (startnew = True) Then Begin
			
			rnd := Random(High(pieces) + 1);
			
			Case rnd Of
				0 : color := 11;
				1 : color := 9;
				2 : color := 6;
				3 : color := 14;
				4 : color := 10;
				5 : color := 5;
				6 : color := 12;
			End;
		
			LoadPiece(rnd);
		
			pr := 0;
			px := (W - 4) Div 2 + 1;
			py := 2;
			
			{ GAME OVER }
			If (IsMoveAllowed(px, py, pr) = False) Then Begin
			
				TextColor(14);

				GotoXY(1, 1);
				Write('GAME ');
				
				GotoXY(W - 4, 1);
				Write(' OVER');

				GotoXY(1, H + 1);
				TextColor(15);
								
				Repeat Until Keypressed;

				Halt;
			End Else Begin
				DrawPiece(px, py, pr, color, SIMB);
				startnew := False;
			End;
		End;

		{ piece is falling}
		
		Repeat
		
			total_ms := 0;
		
			continue := True;
		
			GetTime(wtmp, wtmp, wtmp, old_ms);
		
			While continue Do Begin
				Delay(1);
		
				GetTime(wtmp, wtmp, wtmp, new_ms);
				
				If (new_ms > old_ms) Then Begin
					total_ms := total_ms + new_ms - old_ms;
				End Else
				If (new_ms < old_ms) Then Begin
					total_ms := total_ms + 100 - old_ms + new_ms;
				End;
				
				old_ms := new_ms;
				
				If ((total_ms = time_ms) Or (total_ms > time_ms)) Then continue := False;
				
				If ((continue = True) And (Keypressed)) Then Begin

					{ key is pressed }
				
					ch := ReadKey;
					
					If (ch = #27) Then cancel := True;
					
					If (ch = #32) Then
						Repeat Until Keypressed;
			
					If (ch = #0) Then Begin
			
						ch := ReadKey;
			
						{ up }
						If ((ch = #72) And (IsMoveAllowed(px, py, NewPr()))) Then Begin
							DrawPiece(px, py, pr, color, ' ');
							pr := NewPr();
							DrawPiece(px, py, pr, color, SIMB);
						End;
			
						{ right }
						If ((ch = #77) And (IsMoveAllowed(px + 1, py, pr) = True)) Then Begin
							DrawPiece(px, py, pr, color, ' ');
							Inc(px);
							DrawPiece(px, py, pr, color, SIMB);
						End;
			
						{ left }
						If ((ch = #75) And (IsMoveAllowed(px - 1, py, pr) = True)) Then Begin
							DrawPiece(px, py, pr, color, ' ');
							Dec(px);
							DrawPiece(px, py, pr, color, SIMB);
						End;
			
						{ down }
						If ((ch = #80) And (IsMoveAllowed(px, py + 1, pr) = True)) Then Begin
							DrawPiece(px, py, pr, color, ' ');
							Inc(py);
							DrawPiece(px, py, pr, color, SIMB);
						End;
						
					End; 
					
				End;
				
			End;
	
			If (IsMoveAllowed(px, py + 1, pr) = True) Then Begin
				DrawPiece(px, py, pr, color, ' ');
				Inc(py);
				DrawPiece(px, py, pr, color, SIMB);
			End Else Begin
			
				SaveCurrentPiece;
				
				CheckForFullLines;

				startnew := True;
			End;
			
		Until ((cancel = True) Or (startnew = True));
		
	Until (cancel = True);
	
	TextColor(15);
	GotoXY(1, H + 1);

END.