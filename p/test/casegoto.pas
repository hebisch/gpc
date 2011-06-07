Program CaseGoto;

Label
  42;

Var
  Question: Boolean = false;

begin
  case Question of
    true: repeat
            writeln ( 'failed' );
            42:
            writeln ( 'OK' );
          until not Question;
    false: {$local W-,borland-pascal} goto 42; {$endlocal}
  end { case };
end.
