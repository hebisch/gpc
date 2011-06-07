program fjf850b;

procedure foo (protected var a: Integer); forward;

procedure foo (var a:Integer);  { WRONG }
begin
end;

begin
end.
