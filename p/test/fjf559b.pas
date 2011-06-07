program fjf559b;

procedure foo;

label 9;

begin
  WriteLn ('failed');
  goto 9;
  { WRONG }
end;

begin
  foo
end.
