program fjf493f;

var f: Text;

begin
  with BindingType[Bound: True] do
    if Bound then WriteLn ('OK') else WriteLn ('failed')
end.
