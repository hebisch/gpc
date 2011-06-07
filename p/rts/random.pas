{ Pseudo random number generator

  Copyright (C) 1997-2006 Free Software Foundation, Inc.

  Authors: Frank Heckenbach <frank@pascal.gnu.de>
           Toby Ewing <ewing@iastate.edu>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{$gnu-pascal,I-}

unit Random; attribute (name = '_p__rts_Random');

interface

uses RTSC, Error, Time;

type
  RandomSeedType = Cardinal attribute (Size = 32);
  RandomizeType  = ^procedure;
  SeedRandomType = ^procedure (Seed: RandomSeedType);
  RandRealType   = ^function: LongestReal;
  RandIntType    = ^function (MaxValue: LongestCard): LongestCard;

{@internal}
{ RandomizePtr, SeedRandomPtr, RandRealPtr and RandIntPtr point to these routines by default }
procedure Default_Randomize;                                        attribute (name = '_p_Default_Randomize');
procedure Default_SeedRandom (Seed: RandomSeedType);                attribute (name = '_p_Default_SeedRandom');
function  Default_RandReal: LongestReal;                            attribute (name = '_p_Default_RandReal');
function  Default_RandInt (MaxValue: LongestCard) = s: LongestCard; attribute (name = '_p_Default_RandInt');

{ GPC_Randomize, SeedRandom, GPC_RandReal and GPC_RandInt call the actual routines through RandomizePtr, RandRealPtr and RandIntPtr }
procedure GPC_Randomize; attribute (name = '_p_Randomize');
function  GPC_RandReal: LongestReal; attribute (name = '_p_RandReal');
function  GPC_RandInt (MaxValue: LongestCard): LongestCard; attribute (name = '_p_RandInt');
{@endinternal}

procedure SeedRandom (Seed: RandomSeedType); attribute (name = '_p_SeedRandom');

var
  RandomizePtr : RandomizeType = @Default_Randomize;   attribute (name = '_p_RandomizePtr');
  SeedRandomPtr: SeedRandomType = @Default_SeedRandom; attribute (name = '_p_SeedRandomPtr');
  RandRealPtr  : RandRealType = @Default_RandReal;     attribute (name = '_p_RandRealPtr');
  RandIntPtr   : RandIntType = @Default_RandInt;       attribute (name = '_p_RandIntPtr');

implementation

{ Random number generator from ACM Transactions on Modeling and
  Computer Simulation 8(1) 3-30, 1990. Supposedly it has a period of
  -1 + 2^19937. The original was in C; this translation returns the
  same values as the original. It is called the Mersenne Twister.

  The following code was written by Toby Ewing <ewing@iastate.edu>
  and slightly modified by Frank Heckenbach <frank@pascal.gnu.de>.
  It was inspired by C code written by Makoto Matsumoto and Takuji
  Nishimura, considering the suggestions by Topher Cooper and Marc
  Rieffel in July-August 1997.

  For the C code and descriptions of the Mersenne Twister see
  <http://www.math.sci.hiroshima-u.ac.jp/%7Em-mat/MT/emt.html>.

  GetRandom generates one pseudorandom Integer number which is
  uniformly distributed in its range, for each call. SeedRandom
  (Seed) sets initial values to the working area of 624 words.
  Before GetRandom, SeedRandom must be called once. (The Seed is any
  32-bit Integer except for 0.) }

type
  RandomStateType = Cardinal attribute (Size = 64);
  RandomType = Cardinal attribute (Size = 32);

const
  RandomRange = High (RandomType) + 1;
  MTN = 624;  { Period parameters }
  MTM = 397;
  DefaultSeed = 5489;

var
  mti: Integer;
  mt: array [0 .. MTN - 1] of RandomStateType;  { the array for the state vector }
  RandomInitialized: Boolean = False; attribute (name = '_p_RandomInitialized');

procedure Default_SeedRandom (Seed: RandomSeedType);
{ Initializes mt[MTN] with a seed.
  See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. }
begin
  if Seed = 0 then Seed := DefaultSeed;
  mt[0] := Seed and $ffffffff;
  for mti := 1 to MTN - 1 do
    mt[mti] := (1812433253 * (mt[mti - 1] xor (mt[mti - 1] shr 30)) + mti) and $ffffffff;
  mti := MTN;
  RandomInitialized := True
end;

procedure Default_Randomize;
var
  Seed: RandomSeedType = 0;
  f: file of RandomSeedType;
  b: BindingType;
begin
  Assign (f, '/dev/urandom');
  b := Binding (f);
  if not (b.Bound and b.Special) then
    begin
      Assign (f, '/dev/random');
      b := Binding (f)
    end;
  if b.Bound and b.Special then
    begin
      Reset (f);
      repeat
        Read (f, Seed)
      until Seed <> 0;
      Close (f)
    end;
  if (IOResult <> 0) or (Seed = 0) then
    begin
      Seed := GetUnixTime (Null);
      if Seed <= 0 then Seed := ProcessID
    end;
  Default_SeedRandom (Seed)
end;

function GetRandom: RandomType;
const
  MatrixA = $9908b0df;  { constant vector a }
  UpMask  = $80000000;  { most significant w-r bits }
  LowMask = $7fffffff;  { least significant r bits }
  Mag01: array [0 .. 1] of RandomStateType = (0, MatrixA);
var
  y: RandomStateType;
  kk: Integer;
begin
  if not RandomInitialized then Default_Randomize;
  if mti >= MTN then  { generate MTN words at one time }
    begin
      for kk := 0 to MTN - MTM - 1 do
        begin
          y := (mt[kk] and UpMask) or (mt[kk + 1] and LowMask);
          mt[kk] := mt[kk + MTM] xor (y shr 1) xor Mag01[y and 1]
        end;
      for kk := MTN - MTM to MTN - 2 do
        begin
          y := (mt[kk] and UpMask) or (mt[kk + 1] and LowMask);
          mt[kk] := mt[kk + (MTM - MTN)] xor (y shr 1) xor Mag01[y and 1]
        end;
      y := (mt[MTN - 1] and UpMask) or (mt[0] and LowMask);
      mt[MTN - 1] := mt[MTM - 1] xor (y shr 1) xor Mag01[y and 1];
      mti := 0
    end;
  y := mt[mti];
  Inc (mti);
  y := y xor (y shr 11);
  y := y xor ((y shl 7) and $9d2c5680);
  y := y xor ((y shl 15) and $efc60000);
  y := y xor (y shr 18);
  GetRandom := y
end;

function Default_RandReal: LongestReal;
var y: LongestReal;
begin
  y := GetRandom;
  Default_RandReal := y / RandomRange
end;

function Default_RandInt (MaxValue: LongestCard) = s: LongestCard;
var f, m, r, a, b: LongestCard;
begin
  repeat
    m := MaxValue;
    s := 0;
    f := 1;
    while m > 1 do
      begin
        if m >= RandomRange then
          r := GetRandom
        else
          begin
            a := RandomRange - RandomRange mod m;
            repeat
              b := GetRandom
            until b < a;
            r := b mod m
          end;
        Inc (s, r * f);
        f := f * RandomRange;
        m := (m - 1) div RandomRange + 1
      end
  until (s < MaxValue) or (MaxValue = 0)
end;

procedure GPC_Randomize;
begin
  RandomizePtr^
end;

procedure SeedRandom (Seed: RandomSeedType);
begin
  SeedRandomPtr^ (Seed)
end;

function GPC_RandReal: LongestReal;
begin
  GPC_RandReal := RandRealPtr^
end;

function GPC_RandInt (MaxValue: LongestCard): LongestCard;
begin
  GPC_RandInt := RandIntPtr^ (MaxValue)
end;

end.
