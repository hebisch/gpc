program fjf488ym;

procedure foo (var a: String);
begin
end;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  foo (Copy (a, 1, 1))  { WRONG }
end.
