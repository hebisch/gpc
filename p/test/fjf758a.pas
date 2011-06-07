program fjf758a;

procedure foo;

  procedure bar; forward;  { WRONG }

begin
end;

procedure bar;
begin
end;

begin
  WriteLn ('failed')
end.
