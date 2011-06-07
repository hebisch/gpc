{

 This program tests gpc's constants definitions

 The testdata is taken from iso/iec 10206: 6.3.2

}

{ BUG: Extended Pascal initializers do not work. }

program Test(output);

const
  limit =  43;


type
  indextype   = 1..limit;
  sieve       = set of 1..20;
  vector      = array[indextype] of real;
  quiver      = array[1..10] of vector;
  PunchedCard = array[1..80] of char;
  angle       = real value 0.0;
{$local W-}  { @@ }
  subpolar    = record
                  r     : real;
                  theta : angle;
                end;
{$endlocal}

const
  unity         = 1.0;
  third         = unity/3.0;
  SmallPrimes   = sieve[2,3,5,7,11,13,17,19];
  ZeroVector    = vector[1..limit: 0.0];
  UnitVector    = vector[1: unity otherwise 0];
  ZeroQuiver    = quiver[otherwise ZeroVector];
  BlankCard     = PunchedCard[1..80: ' '];
  blank         = ' ';
  Unit          = subpolar[r:1; theta:0.0];
  Unit_Distance = Unit.r;
  Origin        = subpolar[r,theta:0.0];
  thrust        = 5.3;
  theta         = -2.0;
  warp          = subpolar[r:thrust;theta:theta];
  column1       = BlankCard[1];
  MaxMatrix     = 39;
  pi            = 4 * arctan(1);
  hex_string    = '0123456789ABCDEF';
  hex_digits    = hex_string[1..10];
  mister        =  'Mr.';

{ Prospero doesn't compile this one... }
const
  hex_alpha     = hex_string[index(hex_string,'A')..index(hex_string,'F')];

var
  i, j: Integer;

const
  Eps = 0.000001;

begin
  if Abs (unity - 1) > 0.000001 then WriteLn ('failed 1');
  if Abs (third - 0.33333333333333333333) > Eps then WriteLn ('failed 2');
  if (Low (SmallPrimes) <> 1) or (High (SmallPrimes) <> 20) then WriteLn ('failed 3');
  for i := -100 to 100 do
    case i of
      2, 3, 5, 7, 11, 13, 17, 19: if not (i in SmallPrimes) then WriteLn ('failed 4 ', i);
      otherwise if i in SmallPrimes then WriteLn ('failed 4 ', i)
    end;
  if (Low (ZeroVector) <> 1) or (High (ZeroVector) <> 43) then WriteLn ('failed 5');
  for i := 1 to 43 do
    if Abs (ZeroVector[i]) > Eps then WriteLn ('failed 6 ', i);
  if (Low (UnitVector) <> 1) or (High (UnitVector) <> 43) then WriteLn ('failed 7');
  for i := 1 to 43 do
    if Abs (UnitVector[i] - Ord (i = 1)) > Eps then WriteLn ('failed 8 ', i);
  if (Low (ZeroQuiver) <> 1) or (High (ZeroQuiver) <> 10) then WriteLn ('failed 9');
  for j := 1 to 10 do
    if (Low (ZeroQuiver[j]) <> 1) or (High (ZeroQuiver[j]) <> 43) then WriteLn ('failed 10 ', j);
  for j := 1 to 10 do
    for i := 1 to 43 do
      if Abs (ZeroQuiver[j, i]) > Eps then WriteLn ('failed 11 ', j, ' ', i);
  if (Low (BlankCard) <> 1) or (High (BlankCard) <> 80) then WriteLn ('failed 12');
  for i := 1 to 80 do
    if BlankCard[i] <> ' ' then WriteLn ('failed 13 ', i);
  if blank <> ' ' then WriteLn ('failed 14');
  if Abs (Unit.r - 1) > Eps then WriteLn ('failed 15');
  if Abs (Unit.theta) > Eps then WriteLn ('failed 16');
  if Abs (Unit_Distance - 1) > Eps then WriteLn ('failed 17');
  if Abs (Origin.r) > Eps then WriteLn ('failed 18');
  if Abs (Origin.theta) > Eps then WriteLn ('failed 19');
  if Abs (thrust - 5.3) > Eps then WriteLn ('failed 20');
  if Abs (theta + 2) > Eps then WriteLn ('failed 21');
  if Abs (warp.r - 5.3) > Eps then WriteLn ('failed 22');
  if Abs (warp.theta + 2) > Eps then WriteLn ('failed 23');
  if column1 <> ' ' then WriteLn ('failed 24');
  if MaxMatrix <> 39 then WriteLn ('failed 25');
  if Abs (pi - 3.1415926) > Eps then WriteLn ('failed 26');
  if Length (hex_string) <> 16 then WriteLn ('failed 27');
  if hex_string <> '0123456789ABCDEF' then WriteLn ('failed 28');
  if Length (hex_digits) <> 10 then WriteLn ('failed 29');
  if hex_digits <> '0123456789' then WriteLn ('failed 30');
  if Length (mister) <> 3 then WriteLn ('failed 31');
  if mister <> 'Mr.' then WriteLn ('failed 32');
  if Length (hex_alpha) <> 6 then WriteLn ('failed 34');
  if hex_alpha <> 'ABCDEF' then WriteLn ('failed 35');
  WriteLn('OK')
end.
