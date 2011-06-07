{$no-exact-compare-strings}
program fjf498f5;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo LT (('', '') ) { WRONG }
end.
