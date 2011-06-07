{ BUG: fjf226 (tm;-) }

program fjf226d;

type
  tstring = string (10);
var
  bogus : ^tstring value nil;
begin
  if false and (string2cstring (bogus^) <> nil) then writeln ('failed') else writeln ('OK')
end.
