{ We need this because the test suite couldn't easily quote the
  option as needed here with FL-AG (a general solution seems to
  require either shell array variables (only supported by bash2+
  or so), or complicated and time-consuming quoting. }
{ COMPILE-CMD: fjf380b.cmp }

program fjf380b;

{$L fjf380c.c}
function foo: CString; external name 'foo';

begin
  if CString2String (foo) = 'a --extended-pascal' then WriteLn ('OK') else WriteLn ('failed')
end.
