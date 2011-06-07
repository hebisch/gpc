program fjf904b;

type
  t = LongestInt;

const
  a = CompilerAssert (SizeOf (t) = SizeOf (LongestCard), 42);

begin
  if a = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
