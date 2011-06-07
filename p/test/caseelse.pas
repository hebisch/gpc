Program CaseElse;

Var
  i: Integer;

begin
  i:= 7;
  case i of
    0..6: writeln ( 'failed' );
    8..MaxInt: writeln ( 'failed' );
  else
    if i < 0 then
      begin
        writeln ( 'failed' );
        Halt ( 1 );
      end { if };
    writeln ( 'OK' );
  end { case };
end.
