Program TagNew5;

Type
  VarPtr = ^VarRec;
  VarRec = record
    case Boolean of
      true: ( o: Integer );
      false: ( k: Integer );
  end { VarRec };

Var
  Foo: VarPtr;

begin
  New ( Foo, true );
  writeln ( 'OK' );
end.
