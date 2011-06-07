program fjf339;

var
  f : file;
  i : integer;

begin
  {$I-}
  BlockRead (f, i, 1);
  {$I+}
  if IOResult = 0 then WriteLn ('failed') else WriteLn ('OK')
end.
