program fjf727;

var
  a: CBoolean;
  b: array [1 .. 64] of CBoolean;
  s, t: String (10);

begin
  a := True;
  WriteStr (s, a);
  a := False;
  WriteStr (t, a);
  if (s = 'True') and (t = 'False')
     and (SizeOf (a) >= 1) and (SizeOf (a) <= SizeOf (LongestInt))
     and (SizeOf (b) = 64 * SizeOf (a)) then WriteLn ('OK') else WriteLn ('failed')
end.
