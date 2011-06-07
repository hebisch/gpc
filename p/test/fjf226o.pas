program fjf226o;

{$B-}

type
  tstring = string (10);
var
  bogus : ^tstring value nil;
begin
  if false and (index (bogus^, bogus^) <> 0)
    then writeln ('failed')
    else writeln ('OK')
end.
