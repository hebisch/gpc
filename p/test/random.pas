program random(output);

uses GPC;

const
Size = 110;
tries = 10000;

type
density=array[0..Size] of Integer;

var
den :density;
Count :Integer;
loc :Integer;

begin
SeedRandom(42);
for Count:=0 to Size do
        den[Count] := 0;
for Count:=1 to tries do begin
        loc := round(random * (Size - 10));
        den[loc] := den[loc] + 1;
        end;
for Count:=0 to Size div 10 - 1 do begin
        for loc:=10 * Count to 10 * Count + 9 do
                Write(den[loc]:7);
        WriteLn;
        end;
end.
