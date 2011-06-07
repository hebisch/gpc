program fjf340b;

procedure foo (s : packed array [m .. n : Integer] of Char);
begin
  if (m = 2) and (n = 4) then writeln (s [3 .. 4]) else writeln ('failed')
end;

var a : packed array [2 .. 4] of Char = 'KOK';

begin
  foo (a [2 .. 4])
end.
