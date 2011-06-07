Program Schema1b;

Type
  MySubRange ( upper: Char ) = 'A' .. upper;

Var
  O: MySubRange ( 'O' );
  K: 'A'..'K';

begin
  {$W-}
  O:= 'Onkel';
  K:= 'Katze';
  {$W+}
  if ( SizeOf ( O ) <= 2 * SizeOf (Pointer) ) and ( SizeOf ( K ) = SizeOf (Char) ) then
    writeln ( O, K )
  else
    writeln ( 'failed' );
end.
