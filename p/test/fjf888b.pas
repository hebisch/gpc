program fjf888b;

type
  t = array [1 .. MaxInt div 8] of Char;

var
  p: ^t;
  i: Integer = 2;

begin
  GetMem (p, 10);
  p^[1 .. 3] := 'OKx';
  WriteLn (Copy (p^, 1, i))
end.
