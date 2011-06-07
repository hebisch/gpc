program fjf619c;

type
  t = ^String;

function foo: t;
begin
  foo := @'OK'
end;

begin
  WriteLn (foo^)
end.
