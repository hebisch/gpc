program Chief25;

Type
  string255 = string ( 255 );

Function O ( s : string ) : string255;
Begin
  O := 'O' + s
End;

Function  K : string255;
Begin
   K := 'K'
End;

Function OK ( s : string ) : string255;
Begin
  OK := O ( K )
End;

Begin
  writeln (OK (''))
End.
