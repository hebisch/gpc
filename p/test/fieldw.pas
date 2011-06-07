Program FieldWidths;

{ FLAG --field-widths=1:2:3:41:42 }

Var
  Foo: LongInt = 1000000000000000;
  Bar: LongReal = 3.14159265358979323846264338;
  S: String ( 42 );

begin
  WriteStr ( S, Foo );
  if length ( S ) <> 41 then
    writeln ( 'failed (Foo)' )
  else
    begin
      WriteStr ( S, Bar );
      if length ( S ) <> 42 then
        writeln ( 'failed (Bar)' )
      else
        writeln ( 'OK' );
    end { else };
end.
