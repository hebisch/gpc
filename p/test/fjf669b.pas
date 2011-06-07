program fjf669b;

var
  f: Text;
  s: String (10);

begin
  Rewrite (f);
  Reset (f);
  {$I-}
  ReadLn (f, s);
  ReadLn (f, s);
  {$I+}
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
