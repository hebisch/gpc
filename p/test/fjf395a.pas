program fjf395a;

uses GPC;

type
  ta = ByteBool;
  tb = ShortBool;
  tc = WordBool;
  td = MedBool;
  te = LongBool;
  tf = LongestBool;
  tg = Boolean attribute (Size = 1);
  th = Boolean attribute (Size = 15);
  ti = Boolean attribute (Size = 42);
  tj = Boolean attribute (Size = 64);

var
  aa : ByteCard;
  ab : ShortCard;
  ac : Cardinal;
  ad : MedCard;
  ae : LongCard;
  af : LongestCard;
  ag : Cardinal attribute (Size = 1);
  ah : Cardinal attribute (Size = 15);
  ai : Cardinal attribute (Size = 42);
  aj : Cardinal attribute (Size = 64);
  t  : Cardinal = 42;

procedure Error (const Msg : String);
begin
  WriteLn (Msg);
  Halt
end;

{$define TEST(x)
  var b##x : t##x;
  if (SizeOf (b##x) <> SizeOf (a##x))
    or (BitSizeOf (b##x) <> BitSizeOf (a##x))
    or (AlignOf (b##x) > AlignOf (a##x)) then Error (#x + ' Size');
  b##x := False;  if Ord (b##x) <> 0 then Error (#x + ' False 1');
  b##x := t < 42; if Ord (b##x) <> 0 then Error (#x + ' False 2');
  b##x := True;   if Ord (b##x) <> 1 then Error (#x + ' True 1');
  b##x := t = 42; if Ord (b##x) <> 1 then Error (#x + ' True 2');
  for a##x := 0 to 1 do
    begin
      b##x := t##x (a##x);
      if b##x xor (a##x <> 0) then Error (#x + ' Value ' + Integer2String (a##x));
      if Ord (b##x) <> a##x then Error (#x + ' Ord ' + Integer2String (a##x))
    end;
}

begin
  TEST (a);
  TEST (b);
  TEST (c);
  TEST (d);
  TEST (e);
  TEST (f);
  TEST (g);
  TEST (h);
  TEST (i);
  TEST (j);
  WriteLn ('OK')
end.
