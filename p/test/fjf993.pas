program fjf993;

var
  i: Integer attribute (Size = 64);
  s: String (50);

begin
  i := Low (i);
  WriteStr (s, i);
  if s = '-9223372036854775808' then WriteLn ('OK') else WriteLn ('failed ', s)
end.
