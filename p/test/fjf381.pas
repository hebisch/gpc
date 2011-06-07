program fjf381;

type
  TChars = packed array [1 .. 2] of Char;
  PChars = ^TChars;

var
  s : String (10) = 'OK';
  p : PChars;

begin
  p := PChars (@s [1]);
  WriteLn (p^[1 .. 2])
end.
