Program FieldWidths;

{ FLAG --field-widths=35:37:33:41:42 }

Var
  Foo: LongInt = 1000000000000000;
  Bar: LongReal = 3.14159265358979323846264338;
  S: String ( 42 );
  long_foo : Boolean = sizeof(Foo) > sizeof(Integer);
  long_bar : Boolean = sizeof(Bar) > sizeof(Real);
  ok : Boolean = true;

begin
  WriteStr(S, Foo);
  if (long_foo and (length(S) <> 41))
     or (not(long_foo) and (length(S) <> 35))  then begin
       writeln( 'failed (Foo)' );
       ok := false;
  end;
  WriteStr(S, Bar);
  if (long_bar and (length(S) <> 42))
     or (not(long_bar) and (length(S) <> 37)) then begin
        writeln( 'failed (Bar)' );
        ok := false;
  end;
  if ok then writeln ( 'OK' );
end.
