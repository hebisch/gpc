program fjf488xe;

var
  a : integer = 42;
  b : CString;

begin
  WriteLn ('failed');
  b := NewCString (a);
  WriteLn (CString2String (b), 'K')  { WRONG }
end.
