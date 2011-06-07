program fjf582;

var
  OK: Boolean = True;
  Dummy: Integer = 0;

procedure Check (a, b: SizeType; c: Char; n: Integer);
begin
  if a <> b then
    begin
      WriteLn ('failed ', c, ' ', n);
      OK := False
    end
end;

{ The n in `attribute (Size = n)' must be a compile-time constant, so we
  can't make it a `for' loop counter or so. So we use a macro here. }
{$define PREPARETEST(n)
procedure TestProc##n;
type i = Integer attribute (Size = n);
type c = Cardinal attribute (Size = n);
type w = Word attribute (Size = n);
type b = Boolean attribute (Size = n);
type ai = packed array [1 .. $8000] of i;
type ac = packed array [1 .. $8000] of c;
type aw = packed array [1 .. $8000] of w;
type ab = packed array [1 .. $8000] of b;
begin
  Check (SizeOf (ai), $1000 * n, 'i', n);
  Check (SizeOf (ac), $1000 * n, 'c', n);
  Check (SizeOf (aw), $1000 * n, 'w', n);
  Check (SizeOf (ab), $1000 * n, 'b', n);
  Inc (Dummy)
end;}
{ `Inc (Dummy)' is there to avoid a warning `statement with no
  effect' for each call of this procedure with gcc-3. This means
  that GPC determines at compile-time(!) that all tests will pass.
  This is actually a good thing, but the warning is spurious here. }

{$define TESTS
  TEST (1)
  TEST (2)
  TEST (3)
  TEST (4)
  TEST (5)
  TEST (6)
  TEST (7)
  TEST (8)
  TEST (9)
  TEST (10)
  TEST (11)
  TEST (12)
  TEST (13)
  TEST (14)
  TEST (15)
  TEST (16)
  TEST (17)
  TEST (18)
  TEST (19)
  TEST (20)
  TEST (21)
  TEST (22)
  TEST (23)
  TEST (24)
  TEST (25)
  TEST (26)
  TEST (27)
  TEST (28)
  TEST (29)
  TEST (30)
  TEST (31)
  TEST (32)
  TEST (33)
  TEST (34)
  TEST (35)
  TEST (36)
  TEST (37)
  TEST (38)
  TEST (39)
  TEST (40)
  TEST (41)
  TEST (42)
  TEST (43)
  TEST (44)
  TEST (45)
  TEST (46)
  TEST (47)
  TEST (48)
  TEST (49)
  TEST (50)
  TEST (51)
  TEST (52)
  TEST (53)
  TEST (54)
  TEST (55)
  TEST (56)
  TEST (57)
  TEST (58)
  TEST (59)
  TEST (60)
  TEST (61)
  TEST (62)
  TEST (63)
  TEST (64)
}

{$define TEST PREPARETEST}
TESTS
{$undef TEST}

begin
  {$define TEST(n) TestProc##n;}
  TESTS;
  if OK then WriteLn ('OK')
end.
