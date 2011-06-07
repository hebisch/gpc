program fjf319;

procedure foo (const b : LongInt);
begin
  writeln (Chr (b), 'K')
end;

var a : integer = Ord ('O');

begin
  foo(a)
end.
