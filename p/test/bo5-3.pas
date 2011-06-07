Program BO5_3;

uses
  BO5_3u in 'bo5-3u.pas';

{$X+}

Var
  S: CharArrayPtr;
  p: ^Char;

begin
  New ( S, 2 );
  S^ [ 1 ]:= 'O';
  S^ [ 2 ]:= 'K';
  for p:= @S^ [ 1 ] to @S^ [ 2 ] do
    write ( p^ );
  writeln;
end.
