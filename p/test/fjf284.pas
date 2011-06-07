program fjf284;

type t = string (10);

procedure foo (bar : t); forward;

procedure foo (baz : t); { WRONG }
begin
  writeln (bar)  { !!! baz doesn't work here }
end;

begin
  foo ('failed')
end.
