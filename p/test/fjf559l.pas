program fjf559l;

procedure foo;

label 9;

procedure bar;
begin
  goto 9
end;

begin
  WriteLn ('failed');
9:;
9:;  { WRONG }
end;

begin
  foo
end.
