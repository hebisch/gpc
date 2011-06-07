program fjf669a;

var
  f: Text;

begin
  Rewrite (f);
  Reset (f);
  {$I-}
  ReadLn (f);
  ReadLn (f);
  {$I+}
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
