program Foo;

var
  f: Text;
  s: String (1);

begin
  Rewrite (f);
  Reset (f);
  Read (f, s);
  if not EOF (f) and EOLn (f) then WriteLn ('failed');
  WriteLn ('OK')
end.
