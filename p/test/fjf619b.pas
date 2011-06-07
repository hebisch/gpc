program fjf619b;

type
  t = array [1 .. 2] of Char;

function foo = r: t;
begin
  r[1] := 'O';
  r[2] := 'K'
end;

begin
  WriteLn (foo[1], foo[2])
end.
