program fjf559k;

procedure foo;

label 9;

begin
  goto 9;
9:;
9:;  { WRONG }
end;

begin
  WriteLn ('failed')
end.
