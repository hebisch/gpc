program fjf331c;

var
  a : (foo, bar, baz);

procedure p (var b : byte);
begin
  writeln ('failed')
end;

begin
  p (byte (a)) { WRONG }
end.
