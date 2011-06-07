program fjf488xg;

var
  a : integer = 42;
  b : array [0 .. 10] of Char;

begin
  WriteLn ('failed');
  WriteLn (CString2String (String2CString (a)), 'K')  { WRONG }
end.
