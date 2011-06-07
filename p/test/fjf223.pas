program fjf223;

type PLongInt = ^LongInt;

procedure foo (par : PLongInt);
begin
  writeln (Chr (par^ div 1000000), Chr (par^ mod 1000000))
end;

var
  bar : LongInt = Ord ('O') * 1000000 + Ord ('K');

begin
  foo (@bar)
end.
