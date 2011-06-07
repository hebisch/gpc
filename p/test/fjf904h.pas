program fjf904h;

type
  t = LongestInt;

begin
  if CompilerAssert (SizeOf (t) = SizeOf (LongestCard)) then WriteLn ('OK') else WriteLn ('failed')
end.
