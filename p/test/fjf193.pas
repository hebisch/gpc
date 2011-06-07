program fjf193; { should write OK }
var
  a : Text;
  b : BindingType;
  s : string (42);
begin
  b := Binding (a);
  b.Name := ParamStr (1);
  Bind (a, b);
  Reset (a);
  ReadLn (a, s);
  WriteLn (s [Index (s, 'O') .. Index (s, 'K') ] )
end.
