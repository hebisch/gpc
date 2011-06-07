program fjf497b5;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo NE (('', '') ) { WRONG }
end.
