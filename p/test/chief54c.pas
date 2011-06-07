program chief54c;
var foo, bar : integer;
begin
  foo () := bar; { WRONG }
  Writeln ('failed');
end.
