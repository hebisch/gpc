program fjf166;

procedure p(s:String);
begin
end;

var s:String(42);

begin
  s:='failed';
  Delete(s,1,6);
  Insert('OK',s,1);
  WriteLn(s)
end.
