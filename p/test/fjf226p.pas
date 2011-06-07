program fjf226p;

{$B-}

type
  tstring = string (10);
var
  bogus : ^tstring value nil;
begin
  if false and (pos (bogus^, bogus^) <> 0)
    then writeln ('failed')
    else writeln ('OK')
end.
