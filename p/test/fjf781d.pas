program fjf781d;

var
  c: String (2) = 'OK'; attribute (name = 'foo');

var
  d: String (2); external name 'foo'; attribute (const);

begin
  WriteLn (d)
end.
