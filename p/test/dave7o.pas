{$extended-pascal}

program comp (output);

  var s : packed array [1..4] of char;
      t : packed array [1..3] of char;

begin
  s := 'abc';
  t := 'abc';
  if (s = 'abc') and not (s <> t)
    then writeln ('OK')
    else writeln ('failed')
end.
