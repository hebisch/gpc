program fjf988d;

procedure foo;
begin
  Write ('O');
  Exit (foo);
  WriteLn ('failed')
end;

begin
  foo;
  WriteLn ('K')
end.
