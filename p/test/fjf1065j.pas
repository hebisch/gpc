program fjf1065j;

var
  Foo: Integer;
  Uses: Char;

begin
  if Low (Uses) = Chr (0) then WriteLn ('OK') else WriteLn ('failed')
end.
