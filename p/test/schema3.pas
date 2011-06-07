Program Schema3;

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


Function SizeChar ( Var X: MyArray ): Char;

begin { SizeChar }
  { $debug-tree="X"}
  SizeChar:= chr ( (SizeOf ( X ) + SizeOf (MedInt) - SizeOf (Char)) div SizeOf (MedInt) );
end { SizeChar };


begin
{  writeln ( SizeInt ( O ) : 10, SizeInt ( K ) : 10 ); }
  writeln ( chr ( SizeInt ( O ) ), SizeChar ( K ) );
end.
