{$extended-pascal}

program comp (output);

  var s : packed array [1..4] of char;

begin
  s := 'abc';
  if s = 'abcd '
    then writeln ('failed')
    else writeln ('OK')
end.
