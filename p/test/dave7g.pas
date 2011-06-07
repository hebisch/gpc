program comp (output);

  var c : Char;

begin
  c := 'a';
  if c = ''  { WARN }
    then writeln ('true')
    else writeln ('false')
end.
