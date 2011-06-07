program fjf488yi;

procedure foo (var a: String);
begin
end;

var
  a : integer = 42;

begin
  writeln ('failed');
  halt;
  foo (Trim (a))  { WRONG }
end.
