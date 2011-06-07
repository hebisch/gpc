program fjf868;

var
  foo: Integer;

procedure p;
type a = (@foo = nil) .. True;
begin
  if (Low (a) = False) and (High (a) = True) then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p
end.
