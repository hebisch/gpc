unit orland2u;

interface

procedure baz;

implementation

var bar : string(10); external name 'my_bar';

procedure baz;
begin
  bar := 'OK'
end;

end.
