program fjf559g;

procedure foo;

begin
  WriteLn ('failed');
  goto 9; { WRONG }
9:{ WRONG }
end;

begin
  foo
end.
