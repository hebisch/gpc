program fjf293;

var a : array [low (char) .. high (char)] of integer;

begin
  if sizeof (a) = 1 shl bitsizeof (char) * sizeof (integer)
    then writeln ('OK')
    else writeln ('failed')
end.
