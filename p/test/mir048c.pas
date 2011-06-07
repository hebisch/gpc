program mir048c;
{Integer2StringBaseExt(), checking converted value}
uses GPC;

const NTestConvs = 100;
var x : LongInt;
    i, Base, Width : Integer;
    s : String (4096);
    RandomSeed : RandomSeedType;

procedure TestConv (x : LongInt);
var y  : LongInt;
    ec : Integer;
begin
  for Base in [2, 3, 4, 7, 8, 9, 12, 13, 16, 24, 36] do { actually, only 2, 8, 16 are special }
    begin
      s := Integer2StringBaseExt (x, Base, Width, False, True);
      Val (s, y, ec);
      if x <> y then
        begin
          WriteLn ('failed: value (x y) = (', x, '/', y, ')=', s);
          Halt
        end;
      if ec <> 0 then
        begin
          WriteLn ('failed: garbled characters at end: s = ', s);
          Halt
        end
    end
end;

begin
  RandomSeed := Random (High (RandomSeed));
  SeedRandom (RandomSeed);

  Width := 0;
  for i := 1 to NTestConvs do
    begin
      x := Random ($ffffffff);
      TestConv (x);
      TestConv (-x);
    end;
  for i := 1 to NTestConvs do
    begin
      x := Random ($7fffffffffffffff);
      TestConv (x);
      TestConv (-x);
    end;
  TestConv (0);
  TestConv (-1);
  TestConv (-9223372036854775808);
  TestConv (9223372036854775807);

  WriteLn ('OK')
end.
