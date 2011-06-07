{$no-exact-compare-strings}
program fjf498d5;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo GE (('', '') ) { WRONG }
end.
