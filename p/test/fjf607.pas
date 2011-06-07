program fjf607;

uses fjf607u, fjf607v;

begin
  New (w, 42);  { "warning: overflow in implicit constant conversion" }
  WriteLn ('OK')
end.
