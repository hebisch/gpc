Program fjf13;

Type
  S2 = String ( 2 );

Var
  R: record
    OK: Function: S2;
  end { R };

Function MyOK: S2;

begin { MyOK }
  MyOK:= 'OK';
end { MyOK };

begin
  R.OK:= MyOK;
  writeln ( R.OK );
end.
