Program BitManip;

Var
  K: Integer;

begin
  write ( chr ( ( ( 1 shl 6 ) xor $03 ) or ( 16#3 shl 2 ) ) );
  K:= ord ( 'k' );
  and ( K, not ord ( ' ' ) );
  writeln ( chr ( K ) );
end.
