program fjf559h;

procedure foo;

begin
  WriteLn ('failed');
  goto 9; { WRONG }
end;

begin
  foo
end.
