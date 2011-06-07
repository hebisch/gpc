Program BO5_6;

uses
  BO5_6u in 'bo5-6u.pas';

Var
  OK: CharArray ( 2 );

begin
  OK [ 1, 1 ]:= 'O';
  OK [ 1, 2 ]:= 'A';
  OK [ 2, 1 ]:= 'B';
  OK [ 2, 2 ]:= 'K';
  WriteIt ( OK );
end.
