{$no-exact-compare-strings}
program fjf496d5;

procedure foo (var a: Integer);
begin
end;

begin
  writeln ('failed');
  halt;
  foo ('' >= '')  { WRONG }
end.
