{ Changed to match values in `New' to actual case constants.
  -- Frank, 20030302 }

Program TagNew2;

Type
  VarPtr = ^VarRec;
  VarRec = record
    case tag1: Char of
      'A': ( x: Integer );
      'O': ( case tag2: Char of
               'K': ( y: Integer ) )
  end { VarRec };

Var
  Foo: VarPtr;

begin
  New ( Foo, 'O', 'K' );
  writeln ( Foo^.tag1, Foo^.tag2 );
  Dispose ( Foo, 'O', 'K' );
end.
