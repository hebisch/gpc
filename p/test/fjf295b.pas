Program fjf295b;

Type
  S2 = String ( 2 );


Function MyCopy ( Const S: String ): S2;

Var
  called: Boolean value false; attribute (static);

begin { MyCopy }
  if called then
    begin
      writeln ( 'failed' );
      Halt ( 1 )
    end { if };
  called:= true;
  MyCopy:= Copy ( S, 5, 2 );
end { MyCopy };


begin
  writeln ( MyCopy ( CString2String ( 'foo OK' ) ) );
end.
