program fjf488xf;

var
  a : integer = 42;
  b : array [0 .. 10] of Char;

begin
  WriteLn ('failed');
  WriteLn (CString2String (CStringCopyString (b, a)), 'K')  { WRONG }
end.
