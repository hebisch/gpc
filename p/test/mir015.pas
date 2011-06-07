{ Copying by GPL.
  Copyright assigned to FSF.
  Written by: Mirsad Todorovac <mtodorov2_69@yahoo.com>
}

{ NOTE: set this to MaxN + 1 }
{ FLAG --setlimit=512 }

program mir015(output);

{ The few of next lines are literally taken from GPC manual's instructions for
  Random tests. Internal implementation of set is taken from
  test/chris4.pas }

uses GPC;

const MaxN = 511;
      nTests = 8;

{ This program checks the internal representation of sets. }
{ This representation may change without notice, so do not }
{ refer to it in your programs!                            }

Type
  TSetElement = MedCard;

const
  SetWordSize = BitSizeOf ( TSetElement );

var RandomSeed: RandomSeedType;
    Failed:     Boolean;
    A:          set of 0..MaxN Value [];
    Bar:        packed array [ 0 .. ( MaxN div SetWordSize ) - 1 ] of TSetElement absolute A;
    iter, j, n: Integer;
    InSetBefore,
    InSetAfter: Boolean;
    i1, j1, n1: Integer;

begin
  RandomSeed := Random(High (RandomSeed));
  SeedRandom (RandomSeed);

  { We want to expose potential bug in SETs operation in a parameter
    space of 2^MaxN combinations, which means 2^256 combinations for a
    single A: set of [0..255], this is 1.157908e+077 - or 3.669308e+060
    astronomic years if one iteration lasts 1 ns ... :-P

    This is why we are forced to use a feasible set of test data,
    random if we don't know anything better.
  }

  Failed := False;

  for iter := 1 to nTests do
    begin
      {$ifdef VERBOSE}WriteLn ('iter = ', iter);{$endif}
      for n := 1 to MaxN do
        begin
          A := [];
          for j := 0 to n do
            Include (A, Random(MaxN));
          for j := 0 to MaxN do
            begin
              InSetBefore := j in A;
              Include (A, j);
              InSetAfter := j in A;
              if not InSetAfter then
                begin
                  Failed := True;
                  i1 := iter;
                  j1 := j;
                  n1 := n;
                  Break
                end
            end;
          if Failed then Break;
        end;
      if Failed then Break;
    end;

  if Failed then
    begin
      WriteLn ('failed (', RandomSeed, ') ',
               'After Include (setA, ', j1, ') ', j1, ' NOT IN!!!');
      WriteLn ('dumping set [0..', MaxN,']:');
      for j := 0 to MaxN div SetWordSize - 1 do
        WriteLn (Bar[j]);
      Halt
    end
  else
    WriteLn('OK')

end.
