Program Schema3a;

Type
  MyArray ( u: Char ) = array [ ^B..u ] of MedInt;
  PMyArray = ^MyArray;

Var
  O: MyArray ( 'O' );
  K: MyArray ( 'K' );
  p: PMyArray;  { $debug-tree="P"}

begin
  p:= PMyArray (@O);  { $debug-tree="P"}
  write ( chr ( (SizeOf ( p^ ) + SizeOf (MedInt) - SizeOf (Char)) div SizeOf (MedInt) ) );
  p:= PMyArray (@K);
  write ( chr ( (SizeOf ( p^ ) + SizeOf (MedInt) - SizeOf (Char)) div SizeOf (MedInt) ) );
  writeln;
end.
