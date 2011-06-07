{ FLAG -Werror -Wall -W -O }

program fjf409a;

procedure foo; attribute (noreturn); forward;
procedure foo;
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
