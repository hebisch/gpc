program fjf375;

type
  PString = ^String;

function foo : PString;
begin
  foo := @'OK'
end;

begin
  WriteLn (foo^)
end.
