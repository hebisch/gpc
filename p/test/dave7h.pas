{$extended-pascal}

program comp (output);

  var c : Char;

begin
  c := 'a';
  if c = ''
    then writeln ('failed')
    else writeln ('OK')
end.
