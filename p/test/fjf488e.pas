program fjf488e;

var
  a : char = 'O';
  b : CString;

begin
  b := NewCString (a);
  WriteLn (CString2String (b), 'K')
end.
