program fjf226m;

{$B-}

type tstring = string (10);

var bogus : ^tstring value nil;

begin
  if false and (bogus^ < 'bar')
    then writeln ('failed')
    else writeln ('OK')
end.
