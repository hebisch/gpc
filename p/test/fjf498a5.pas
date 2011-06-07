{$no-exact-compare-strings}
program fjf498a5;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo EQ (('', '') ) { WRONG }
end.
