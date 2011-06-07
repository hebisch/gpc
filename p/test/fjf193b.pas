program fjf193b(Output);
{ FLAG --extended-pascal }

var
  a : bindable Text;
  b : BindingType;
  s : string (42);
begin
  b := Binding (a);
  b.Name := 'test.dat';
  Bind (a, b);
  Rewrite (a);
  WriteLn (a, '{ should write OK }');
  Reset (a);
  ReadLn (a, s);
  WriteLn (s [Index (s, 'OK') .. Index (s, 'OK')+1 ] )
end.
