unit fjf260v;

interface

procedure foo; attribute (name = 'vfoo');

implementation

procedure foo;
begin
  writeln ('failed')
end;

end.
