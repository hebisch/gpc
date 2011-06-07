Program CstPar1a;


Const
  y: Char = 'O';


begin
  write ( y );
  {$W-} y:= 'K'; {$W+}
  { warning: typed constants misused as initial variables }
  writeln ( y );
end.
