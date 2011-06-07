{ Test of the HeapMon unit }

program HeapMonTest;

uses HeapMon;

var
  a : array [1 .. 100] of Pointer;
  p : Pointer;
  i, j : Integer;

begin
  Randomize;
  for i := 1 to 100 do
    if Random (1000) = 0
      then a [i] := nil
      else GetMem (a [i], Random (1000));
  for i := 100 downto 2 do
    begin
      j := Random (i) + 1;
      p := a [i];
      a [i] := a [j];
      a [j] := p
    end;
  for i := 1 to 100 do Dispose (a [i]);
  WriteLn ('OK')
end.
