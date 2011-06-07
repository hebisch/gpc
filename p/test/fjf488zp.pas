program fjf488zp;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo (Pos ('', ''))  { WRONG }
end.
