program fjf193a(Output); { should write failed }

procedure Check;
begin
  if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end;

{$I-}
{$extended-pascal}

var
  a : Text;
  b : BindingType;

begin
  b := Binding (a);
  b.Name := 'fjf193a.pas';
  Bind (a, b);
  Check
end.
