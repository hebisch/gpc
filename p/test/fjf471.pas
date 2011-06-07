{ FLAG -Werror }

program fjf471;

type PString = ^String;

function POK : PString;
begin
  POK := @'OK'
end;

begin
  WriteLn (POK^)
end.
