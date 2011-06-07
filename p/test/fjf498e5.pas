{$no-exact-compare-strings}
program fjf498e5;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo GT (('', '') ) { WRONG }
end.
