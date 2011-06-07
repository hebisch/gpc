Program Markus1;

  uses
    Markus1A, Markus1B;

begin
  { Fixed: Parent objects loaded from GPI files were not recognized. }
  s:= New ( NachfahrPtr, init );
  Dispose ( s, fini );
end.
