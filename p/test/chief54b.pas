program chief54b;
var foo, bar : integer;
begin
  foo := bar (); { WRONG }
  Writeln ('failed');
end.
