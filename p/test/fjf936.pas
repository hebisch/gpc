program fjf936;

var
  f: Text;
  s: String (10);

begin
  Rewrite (f);
  Write (f, 'OK');
  Reset (f);
  ReadLn (f, s);
  WriteLn (s)
end.
