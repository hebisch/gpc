program fjf149a;

type Card1 = Cardinal attribute (Size = 1);

type a = packed array [1 .. 2, 1 .. 21] of Card1;

begin
  if (BitSizeOf (a) >= 42) and (BitSizeOf (a) <= 2 * BitSizeOf (LongestInt)) then
    WriteLn ('OK')
  else
    WriteLn ('Failed: ', BitSizeOf (a))
end.
