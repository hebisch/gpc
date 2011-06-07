program fjf327;

var
  a : CCardinal = High (CCardinal) - 2;
  c : LongInt;

begin
  c := - a;
  if c = 2 - LongInt (High (CCardinal)) then writeln ('OK') else writeln ('failed ', c)
end.
