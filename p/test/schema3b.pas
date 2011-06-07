Program Schema3b;

Type
  MyArray ( u: Char ) = array [ ^B..u ] of MedInt;

Var
  O: MyArray ( 'O' );
  K: MyArray ( 'K' );


Function SizeInt ( Var X: MyArray ): Integer;

begin { SizeInt }
  { $debug-tree="X"}
  SizeInt:= (SizeOf ( X ) + SizeOf (MedInt) - SizeOf (Char)) div SizeOf (MedInt);
end { SizeInt };


begin
  if ( SizeInt ( O ) = Ord ('O') ) and ( SizeInt ( K ) = Ord ('K') ) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', SizeInt ( O ), ' ', SizeInt ( K ))
end.
