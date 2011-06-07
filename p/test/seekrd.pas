Program Test ( Output );

Var
  Data: File [ 0..25 ] of Char;
  C: Char;

begin
  rewrite ( Data );
  for C:= 'A' to 'Z' do
    write ( Data, C );
  reset ( Data );
  SeekRead ( Data, ord ( 'O' ) - ord ( 'A' ) );
  read ( Data, C );
  write ( C );
  SeekRead ( Data, ord ( 'K' ) - ord ( 'A' ) - 1 );
  read ( Data, C );
  read ( Data, C );
  writeln ( C );
end.
