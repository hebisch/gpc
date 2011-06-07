Program VoidParm;


Type
  TwoBytes = packed array [ 1..2 ] of Char;


Var
  KO, OK: TwoBytes;


Procedure MoveTwoBytes ( Const Source; Var Dest );

Var
  S: TwoBytes absolute Source;
  D: TwoBytes absolute Dest;

begin { MoveTwoBytes }
  D:= S;
end { MoveTwoBytes };


begin
  KO [ 2 ]:= 'K';
  KO [ 1 ]:= 'O';
  MoveTwoBytes ( KO, OK );
  writeln ( OK );
end.
