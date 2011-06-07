program chief40;

var
  a : LongInt;
  b : Byte;

const
  MaxCInt = High (CInteger);

begin
  a := 2 * MaxCInt;
  b := 10;
  a := 2 * a + b;
  if (a = 4 * MaxCInt + 10) and (a > MaxCInt) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', a, ' ', 4 * MaxCInt + 10, ' ', a > MaxCInt)
end.
