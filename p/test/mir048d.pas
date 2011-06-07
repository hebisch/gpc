program mir048d;
{Integer2StringBase(), checking converted value}
uses GPC;

const NTestConvs = 100;
var x : LongInt;
    i, Base, Width, ec : Integer;
    s : String (4096);
    RandomSeed : RandomSeedType;

procedure ValBase (s: String; var y: LongInt; ec: Integer; Base: Integer);
var s1 : String (4096);
begin
  if s[1] = '-' then
    s1 := '-' + Integer2String (Base) + '#' + s[2..Length (s)]
  else
    s1 := Integer2String (Base) + '#' + s;
  Val (s1, y, ec);
end;

procedure TestConv (x : LongInt);
var y : LongInt;
begin
  for Base in [2, 3, 4, 7, 8, 9, 12, 13, 16, 24, 36] do { actually, only 2, 8, 16 are special }
    begin
      s := Integer2StringBase (x, Base);
      ValBase (s, y, ec, Base);
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
