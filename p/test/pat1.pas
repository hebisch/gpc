Program Pat1;

Type
  Monitor_Type = ( CO40, CO80, FOO, BAR );

Var
  Monitor: Monitor_Type value CO40;

begin
  if Monitor in [CO40,CO80] then
    writeln ( 'OK' );
end.
