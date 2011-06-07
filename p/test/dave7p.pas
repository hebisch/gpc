{$W-}

program comp (output);

  var s : packed array [1..4] of char;
      t : packed array [1..3] of char;
      u : String (3);

begin
  s := 'abc';
  u := 'abc';
  if (s = 'abc') or not (s <> t) or ('abcde' = u) or (u = 'abcde')
    then writeln ('failed')
    else writeln ('OK')
end.
