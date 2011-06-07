program Chuck4;

CONST N = 10;
TYPE emptyrecord = record end;
TYPE tper      = ^emptyrecord;
VAR  per: tper;
VAR  erarray  : ARRAY[1..N] OF emptyrecord;
VAR  i, j: Integer;

begin
i := 2;
j := 4;
new(per);
erarray[i] := erarray[j];
erarray[i] := per^;
per^ := erarray[i];
dispose(per);
WriteLn ('OK')
end.
