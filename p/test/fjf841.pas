program fjf841;

procedure Msg (const Msg: String); attribute (noreturn);
begin
  WriteLn (Msg);
  Halt
end;

var
  p: procedure (const s: String);

begin
  p := Msg;
  p ('OK')
end.
