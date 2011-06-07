{ @@ DosEmu (0.98.4.0, Linux 2.2.13) crashes. Perhaps a memory
     problem. Not inlining (Test) helps. }
{ FLAG --no-inline-functions }

program fjf444a;

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
  f1 : Integer = -3;
  g1 : TCard = 3;
  h1 : TCard = $fffffffd;

const
  e2 : Integer = 3;
  f2 : Integer = -3;
  g2 : TCard = 3;
  h2 : TCard = $fffffffd;

  e3 = Integer (3);
  f3 = Integer (-3);
  g3 = TCard (3);
  h3 = TCard ($fffffffd);

{$define e4 Integer (3)}
{$define f4 Integer (-3)}
{$define g4 TCard (3)}
{$define h4 TCard ($fffffffd)}

{$define e5 3}
{$define f5 -3}
{$define g5 3}
{$define h5 $fffffffd}

procedure Test (Cond : Boolean; const Msg : String);
begin
  if not Cond then
    begin
      WriteLn ('failed: not (', Msg, ')');
      Halt
    end
end;

{$define TEST(Cond) Test (Cond, #Cond)}

{$define TEST1(i, j)
procedure Test##i##j;
begin
  TEST ((a##i) div (e##j) = 1);
  TEST ((b##i) div (e##j) = -1);
  TEST ((c##i) div (e##j) = 1);
  TEST ((d##i) div (e##j) = $55555553);
  TEST ((a##i) div (f##j) = -1);
  TEST ((b##i) div (f##j) = 1);
  TEST ((c##i) div (f##j) = -1);
  TEST ((d##i) div (f##j) = -$55555553);
  TEST ((a##i) div (g##j) = 1);
  TEST ((b##i) div (g##j) = -1);
  TEST ((c##i) div (g##j) = 1);
  TEST ((d##i) div (g##j) = $55555553);
  TEST ((a##i) div (h##j) = 0);
  TEST ((b##i) div (h##j) = 0);
  TEST ((c##i) div (h##j) = 0);
  TEST ((d##i) div (h##j) = 0);
end;
}

{$define TEST2(i)
  TEST1 (i, 1)
  TEST1 (i, 2)
  TEST1 (i, 3)
  TEST1 (i, 4)
  TEST1 (i, 5)
}

TEST2 (1)
TEST2 (2)
TEST2 (3)
TEST2 (4)
TEST2 (5)

{$define DOTEST2(i)
  Test##i##1;
  Test##i##2;
  Test##i##3;
  Test##i##4;
  Test##i##5;
}

begin
  DOTEST2(1);
  DOTEST2(2);
  DOTEST2(3);
  DOTEST2(4);
  DOTEST2(5);
  WriteLn ('OK')
end.
