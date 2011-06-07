{$extended-pascal}

program fjf895 (Output);

var
  f: bindable Text;
  b: BindingType;
  s: String (10);

begin
  b := Binding (f);
  b.Name := 'non-existing-dir/foo';
  Bind (f, b);
  if Binding(f).Bound then
    begin
      WriteLn ('failed');
      Halt
    end;
  Rewrite (f);
  WriteLn (f, 'OK');
  Reset (f);
  ReadLn (f, s);
  WriteLn (s)
end.
