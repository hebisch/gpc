Program CaseOtherw;

Var
  i: Integer;

begin
  i:= 7;
  case i of
    0..6:
      writeln ( 'failed' );
    8..MaxInt:
      case i of
        8..42: writeln ( 'failed' );
      otherwise
        writeln ( 'failed' );
      end { case };
  otherwise
    if i < 0 then
      begin
        writeln ( 'failed' );
        Halt ( 1 );
      end { if };
    writeln ( 'OK' );
  end { case };
end.
