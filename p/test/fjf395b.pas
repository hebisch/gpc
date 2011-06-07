program fjf395b;

uses GPC;

type
  ta = ByteBool;
  tb = ShortBool;
  tc = WordBool;
  td = MedBool;
  te = LongBool;
  tf = LongestBool;
  th = Boolean attribute (Size = 15);
  ti = Boolean attribute (Size = 42);
  tj = Boolean attribute (Size = 64);

  ca = ByteCard;
  cb = ShortCard;
  cc = Cardinal;
  cd = MedCard;
  ce = LongCard;
  cf = LongestCard;
  ch = Cardinal attribute (Size = 15);
  ci = Cardinal attribute (Size = 42);
  cj = Cardinal attribute (Size = 64);

var
  aa : ByteInt;
  ab : ShortInt;
  ac : Integer;
  ad : MedInt;
  ae : LongInt;
  af : LongestInt;
  ah : Integer attribute (Size = 15);
  ai : Integer attribute (Size = 42);
  aj : Integer attribute (Size = 64);
  t  : Integer = 42;

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
      if Ord (b##x) <> c##x (a##x) then Error (#x + ' Ord ' + Integer2String (a##x))
    end;
}

begin
  TEST (a);
  TEST (b);
  TEST (c);
  TEST (d);
  TEST (e);
  TEST (f);
  TEST (h);
  TEST (i);
  TEST (j);
  WriteLn ('OK')
end.
