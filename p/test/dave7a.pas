program comp (output);

  var s : packed array [1..4] of char;

begin
  s := 'abc';
  if s = 'abc'  { WARN }
    then writeln ('true')
    else writeln ('false')
end.
