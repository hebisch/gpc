{$no-exact-compare-strings}
program fjf498b5;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo NE (('', '') ) { WRONG }
end.
