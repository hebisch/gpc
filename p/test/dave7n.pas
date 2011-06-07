program comp (output);

  var u : String (3);

begin
  u := 'abc';
  if u = 'abcde'  { WARN }
    then writeln ('true')
    else writeln ('false')
end.
