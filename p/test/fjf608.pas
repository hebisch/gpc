program fjf608;

uses fjf608u, fjf608v;

begin
  New (w, 42);  { "warning: overflow in implicit constant conversion" }
  WriteLn ('OK')
end.
