program fjf670 (Output, f);

var
  f: bindable Text;
  b: BindingType;

procedure BindFile (var f: Text);
var
  b: BindingType;
begin
  Unbind (f);
  b := Binding (f);
  b.Name := ParamStr (1);
  Bind (f, b);
  b := Binding (f);
  if not b.Bound then
    begin
      WriteLn ('file not bound');
      Halt
    end
end;

begin
  BindFile (f);
  b := Binding (f);
  if b.Existing then
    WriteLn ('OK')
  else
    WriteLn ('file does not exist')
end.
