program PackedCharArrayTest(input, output);
{$extended-pascal}
type

char_arr = packed array[1..30] of char;

smallrec = RECORD
  arr : char_arr;
END;

largerec = packed RECORD
  one_rec     : smallrec;
  many_rec    : array[1..5] of smallrec;
  one_array   : char_arr;
  many_arrays : array[1..5] of char_arr;
END;

VAR
  r: largerec;
  c, c1: char_arr;
  aSmallrec: smallrec;
  aSmallrecArray: array[1..5] of smallrec;
  i: integer;

begin
for i := 1 to 30 do
  c[i] := chr(i);
c1 := c;
aSmallrec.arr := c;
aSmallrecArray[1].arr := c;
r.many_rec[1].arr := c; {compiler error but ISO7185/10206 legal}

if (c1 = c)
   and (aSmallrec.arr = c)
   and (aSmallrecArray[1].arr = c)
   and (r.many_rec[1].arr = c) then
  WriteLn ('OK')
else
  WriteLn ('failed')

END.
