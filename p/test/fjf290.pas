{ FLAG -Werror }

program fjf290;

var i : cardinal;

begin
  i := 7;
  if i in [0..42] then writeln ('OK') else writeln ('failed')
end.
