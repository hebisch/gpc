program fjf488zo;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo (Index ('', ''))  { WRONG }
end.
