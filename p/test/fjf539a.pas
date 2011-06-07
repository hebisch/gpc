program fjf539a;

{$define x 'bar'}

var
  a: String (10) = 'OK'; attribute (name = 'fred');
  b: String (10); external name 'fr' 'ed';

procedure qux; external name 'fo' 'obar';

procedure foo; attribute (name = 'foo' x);
begin
  WriteLn (b)
end;

begin
  qux
end.
