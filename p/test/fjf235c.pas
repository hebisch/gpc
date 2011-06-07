program fjf235c;

var a : (foo,bar);

begin
  if a >= 0 then; { WRONG }
  writeln ('failed')
end.
