program fjf349;

var
  p : word = 2;

begin
  if length (copy ('foo', 1, p - 1)) = 1
    then writeln ('OK')
    else writeln ('failed: ', length (copy ('foo', 1, p - 1)))
end.
