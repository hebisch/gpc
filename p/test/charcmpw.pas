Program CharCmpW;

Var
  A: Char value chr ( 1 );
  O: Char value 'O';

begin
  if A = ( 'K' < O ) then  { WRONG }
    writeln ( 'failed' );
end.
