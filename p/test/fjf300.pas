program fjf300;
{$W-}
var a : integer absolute pointer (1); { WRONG }

begin
  writeln ('failed')
end.
