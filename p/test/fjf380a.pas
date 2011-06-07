{ We need this because the test suite couldn't easily quote the
  option as needed here with FL-AG (a general solution seems to
  require either shell array variables (only supported by bash2+
  or so), or complicated and time-consuming quoting. }
{ COMPILE-CMD: fjf380a.cmp }

program fjf380a;

{ BUG: Command line arguments passed to recursive automake compiler
       invocations are not properly quoted }

uses fjf380u;

begin
end.
