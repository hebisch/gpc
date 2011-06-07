program fjf436h;

const
  k = Succ ('J');

procedure p (c, d : CString);
begin
  WriteLn (CString2String (c), CString2String (d))
end;

begin
  p (Pred ('P'), k)
end.
