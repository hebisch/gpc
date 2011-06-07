program fjf559i;

procedure foo;

label 9;

procedure bar;
begin
  goto 9
end;

begin
  WriteLn ('failed');
  { WRONG }
end;

begin
  foo
end.
