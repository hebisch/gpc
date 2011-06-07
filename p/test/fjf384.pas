program fjf384;

var
  s, t : set of Char;

begin
  s := ['a' .. 'z'];
  t := ['A' .. 'Z'];
  { The old implementation of `Card' would overwrite sets }
  if (Card (s) = 26) and (Card (s) = 26) and
     (Card (s + t) = 52) and (Card (s + t) = 52)
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
