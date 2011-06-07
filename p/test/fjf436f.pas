program fjf436f;

const
  k = Succ ('J');

function c: CString;
begin
  c := Pred ('P')
end;

function d: CString;
begin
  Return k
end;

begin
  WriteLn (CString2String (c), CString2String (d))
end.
