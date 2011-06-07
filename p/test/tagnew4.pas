{ Changed to match values in `New' to actual case constants.
  -- Frank, 20030302 }

Program TagNew4;

Type
  MyChar = ( a, b, c, d, e, f, g, h, i, j, k, l, m, n, o );
  VarPtr = ^VarRec;
  VarRec = record
    case tag1: MyChar of
      a: ( x: Integer );
      k, o: ( case tag2: 0..255 of
                ord ('K'): ( y: Integer ) )
  end { VarRec };

Var
  Foo: VarPtr;

begin
  New ( Foo, o, ord ( 'K' ) );
  writeln ( chr ( ord ( 'A' ) + ord ( Foo^.tag1 ) ),
            chr ( Foo^.tag2 ) );
  Dispose ( Foo, 'O', 'K' );
end.
