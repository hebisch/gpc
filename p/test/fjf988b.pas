program fjf988b;

procedure foo;
begin
  WriteLn ('OK');
  Exit (program);
  WriteLn ('failed 1')
end;

begin
  foo;
  WriteLn ('failed 2')
end.
