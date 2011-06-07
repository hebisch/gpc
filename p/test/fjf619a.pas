program fjf619a;

type
  t = record o, k: Char end;

function foo = r: t;
begin
  r.o := 'O';
  r.k := 'K'
end;

begin
  WriteLn (foo.o, foo.k)
end.
