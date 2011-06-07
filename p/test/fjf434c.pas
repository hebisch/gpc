{ Fails on Alpha/OSF ... }

{ @@ DosEmu (0.98.4.0, Linux 2.2.13) crashes. Perhaps a memory
     problem. Not inlining (Test) helps. }
{ FLAG --no-inline-functions }

program fjf434c;

type
  TCard = Cardinal attribute (Size = 32);

var
  a1 : Integer = 5;
  b1 : Integer = -5;
  c1 : TCard = 5;
  d1 : TCard = $fffffffa;

const
  a2 : Integer = 5;
  b2 : Integer = -5;
  c2 : TCard = 5;
  d2 : TCard = $fffffffa;

  a3 = Integer (5);
  b3 = Integer (-5);
  c3 = TCard (5);
  d3 = TCard ($fffffffa);

{$define a4 Integer (5)}
{$define b4 Integer (-5)}
{$define c4 TCard (5)}
{$define d4 TCard ($fffffffa)}

{$define a5 5}
{$define b5 -5}
{$define c5 5}
{$define d5 $fffffffa}

var
  e1 : Integer = 3;
  g1 : TCard = 3;
  h1 : TCard = $fffffffd;

const
  e2 : Integer = 3;
  g2 : TCard = 3;
  h2 : TCard = $fffffffd;

  e3 = Integer (3);
  g3 = TCard (3);
  h3 = TCard ($fffffffd);

{$define e4 Integer (3)}
{$define g4 TCard (3)}
{$define h4 TCard ($fffffffd)}

{$define e5 3}
{$define g5 3}
{$define h5 $fffffffd}

var
  OK: Boolean = True;

procedure Test (Cond: Boolean; const Msg: String; Val2: LongestInt);
begin
  if not Cond then
    begin
      WriteLn ('failed: not (', Msg, ') [', Val2, ']');
      OK := False
    end
end;

{$define TESTC(Cond, Val2) Test (Cond, #Cond, Val2)}

{$define TEST(Val1, Val2) TESTC (Val1 = Val2, Val1)}

{$define TEST1(i, j)
  TEST ((a##i) mod (e##j), 2);
  TEST ((b##i) mod (e##j), 1);
  TEST ((c##i) mod (e##j), 2);
  TEST ((d##i) mod (e##j), 1);
  TEST ((a##i) mod (g##j), 2);
  TEST ((b##i) mod (g##j), 1);
  TEST ((c##i) mod (g##j), 2);
  TEST ((d##i) mod (g##j), 1);
  TEST ((a##i) mod (h##j), 5);
  TEST ((b##i) mod (h##j), $fffffff8);
  TEST ((c##i) mod (h##j), 5);
  TEST ((d##i) mod (h##j), $fffffffa);
}

{$define TEST2(i)
  TEST1 (i, 1)
  TEST1 (i, 2)
  TEST1 (i, 3)
  TEST1 (i, 4)
  TEST1 (i, 5)
}

begin
  TEST2 (1)
  TEST2 (2)
  TEST2 (3)
  TEST2 (4)
  TEST2 (5)
  if OK then WriteLn ('OK')
end.
