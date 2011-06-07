program fjf436e;

const
  k = Succ ('J');

var
  c, d : CString;

begin
  c := Pred ('P');
  d := k;
  WriteLn (CString2String (c), CString2String (d))
end.
