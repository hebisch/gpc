{$W-}
{ Test of the System unit }

{ FLAG --autobuild -D__BP_RANDOM__ }

program SystemTest;

uses System;

var
  p: Pointer;
  c: Integer;

procedure Error (const Msg: String);
begin
  WriteLn ('Error in ', Msg);
  Halt (1)
end;

function HeapErrorRetryFunc (Size: Word): Integer;
begin
  WriteLn ('OK');
  Halt;
  HeapErrorRetryFunc := 0
end;

begin
  if Lo ($12345678) <> $78 then Error ('Lo');
  if Hi ($12345678) <> $56 then Error ('Hi');
  if Swap ($12345678) <> $7856 then Error ('Swap');
  RandSeed := $3eadbeef;
  if Random (17) <> 4 then Error ('Random #1');
  if Random (42) <> 23 then Error ('Random #2');
  if Abs (Random - 0.965797) > 1e-6 then Error ('Random #3');
  HeapError := @HeapErrorNilReturn;
  GetMem (p, 1);
  if p = nil then Error ('HeapError #1');
  c := $100;
  repeat
    Dec (c);
    GetMem (p, High (SizeType) div 2 - $100)
  until (c = 0) or (p = nil);
  if p <> nil then
    begin
      WriteLn ('SKIPPED: too much memory 1 ;-)');
      Halt
    end;
  HeapError := @HeapErrorRetryFunc;
  c := $100;
  repeat
    Dec (c);
    GetMem (p, High (SizeType) div 2 - $100)
  until c = 0;
  if p <> nil then
    begin
      WriteLn ('SKIPPED: too much memory 2 ;-)');
      Halt
    end
end.
