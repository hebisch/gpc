program testmem;

type
  Fieldary(sY, sZ : medCard) = array[1..sY,1..sZ] of Real;
  FPary(sX : medCard)        = array[0..sX] of ^Fieldary;

var
  Field       : ^FPary;
  i, j, k     : byteCard;
  nx, ny, nz  : medCard;

begin
  nx := 4;
  ny := 5;
  nz := 6;
  New(Field, nx);
  for i := 0 to nx do New(Field^[i], ny, nz);
  for i := 0 to nx do
    for j := 1 to nx do
      for k := 1 to nx do Field^[i]^[j,k] := 1.0 * i * j * k;
  for i := 0 to nx do Dispose(Field^[i]);
  Dispose(Field);
  WriteLn ('OK')
end.
