program fjf963b;

var
  Called: Boolean = False;

function f: Integer;
begin
  if Called then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  Called := True;
  f := 1
end;

begin
  if (ParamStr (f) <> '') and_then Called then WriteLn ('OK') else WriteLn ('failed')
end.
