program fjf563c;

const
  { The initializer is WRONG because the set type is truncated.
    This might be ok in some future GPC version, but GPC should
    not crash (like it did). }
  s: set of 0 .. 100000 = [100000];

begin
  WriteLn ('failed')
end.
