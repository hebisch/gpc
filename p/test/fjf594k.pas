program fjf594k;

type
  t = ^Integer;

var
  i: restricted t;

begin
  New (i);
  if i = nil then WriteLn ('huh?');  { operation with restricted object }   { WRONG }
  WriteLn ('failed')
end.
