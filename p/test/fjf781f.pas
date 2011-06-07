program fjf781f;

var
  c: Char = 'O'; attribute (volatile, name = 'foo');

var
  d: Char; external name 'foo'; attribute (volatile, const);

begin
  Write (d);
  c := 'K';
  WriteLn (d)
end.
