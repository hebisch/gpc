program fjf340a;

procedure foo (s : String);
begin
  if length (s) = 3 then writeln (s [2 .. 3]) else writeln ('failed')
end;

var a : packed array [2 .. 4] of Char = 'KOK';

begin
  foo (a [2 .. 4])
end.
