program fjf404;

procedure foo (procedure bar (x : Integer));
begin
  WriteLn ('failed')
end;

procedure bar (x : Word);
begin
end;

begin
  foo (bar) { WRONG }
end.
