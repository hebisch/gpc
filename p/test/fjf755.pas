{ FLAG --extended-pascal --transparent-file-names -w }

program fjf755 (Output, StdErr);

var
  StdErr, Foo: Text;
  s: String (2);

procedure Assign (var t: Text; protected Name: String);
var B: BindingType;
begin
  Unbind (t);
  B := Binding (t);
  B.Name := Name;
  Bind (t, B)
end;

begin
  Rewrite (StdErr);
  WriteLn (StdErr, 'OK');
  Assign (Foo, 'StdErr');
  Reset (Foo);
  ReadLn (Foo, s);
  WriteLn (s);
  {$gnu-pascal}
  Erase (StdErr)
end.
