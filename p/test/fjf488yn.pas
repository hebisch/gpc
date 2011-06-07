program fjf488yn;

procedure foo (var a: String);
begin
end;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  foo (SubStr (a, 1, 1))  { WRONG }
end.
