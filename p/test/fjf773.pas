program fjf773;

procedure p1;
begin
  WriteLn ('OK')
end;

procedure p2 (procedure a);
begin
  a
end;

procedure p3 (procedure a (procedure b));
begin
  a (p1)
end;

procedure p4 (procedure a (procedure b (procedure c)));
begin
  a (p2)
end;

begin
  p4 (p3)
end.
