unit fjf260w;

interface

uses fjf260v;

procedure foo; attribute (name = 'wfoo');

implementation

procedure foo;
begin
  writeln ('OK')
end;

end.
