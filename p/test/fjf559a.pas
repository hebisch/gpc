program fjf559a;

procedure foo;

label 9;

begin
  goto 9;
  WriteLn ('failed');
  Halt;
9:WriteLn ('OK')
end;

begin
  foo
end.
