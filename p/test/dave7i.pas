program comp (output);

  var c : Char;

begin
  c := 'a';
  if c = 'ab'  { WARN }
    then writeln ('true')
    else writeln ('false')
end.
