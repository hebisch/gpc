program foo (input);

var s: String (2);

begin
  while input^in [' ', "\t"] do
    get (input);
  ReadLn (s);
  WriteLn (s)
end.
