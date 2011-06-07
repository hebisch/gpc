program fjf596;

type
  Natural = 1 .. MaxInt;

procedure p (a: array [m .. n: Natural] of Char);
var i: Integer;
begin
  for i := m to n do Write (a[i]);
  WriteLn
end;

type
  s (d: Integer) = array [1 .. d] of Char;

var
  v: s (2);

begin
  v[1] := 'O';
  v[2] := 'K';
  p (v)
end.
