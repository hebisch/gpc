{ FLAG -Werror -Wall -W -O }

program fjf409b;

procedure foo; attribute (noreturn);
begin
  WriteLn ('OK');
  Halt
end;

function bar : Integer;
begin
  if False then bar := 42;
  foo
end;

begin
  WriteLn (bar)
end.
