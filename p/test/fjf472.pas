{ FLAG -Werror }

program fjf472;

type PString = ^String;

function f : PString;
begin
  f := PString (@'OK')
end;

begin
  WriteLn (f^)
end.
