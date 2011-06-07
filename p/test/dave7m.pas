program comp (output);

  var u : String (3);

begin
  u := 'abc';
  if 'abcde' = u  { WARN }
    then writeln ('true')
    else writeln ('false')
end.
