unit fjf260u;

interface

procedure foo; attribute (name = 'ufoo');

implementation

procedure foo;
begin
  writeln ('failed')
end;

end.
