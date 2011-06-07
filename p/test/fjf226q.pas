program fjf226q;

{$B-}

type
  charset = set of char;
var
  bogus : ^charset value nil;
begin
  if false and (card (bogus^) <> 0)
    then writeln ('failed')
    else writeln ('OK')
end.
