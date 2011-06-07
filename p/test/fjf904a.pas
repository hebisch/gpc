program fjf904a;

type
  t = LongestInt;

const
  a = CompilerAssert (SizeOf (t) = SizeOf (LongestCard));

begin
  if a then WriteLn ('OK') else WriteLn ('failed')
end.
