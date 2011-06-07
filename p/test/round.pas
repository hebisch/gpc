Program RoundTest;

Procedure WriteChar ( AscVal: Integer );

begin { WriteChar }
  write ( chr ( abs ( AscVal ) ) );
end { WriteChar };

begin
  WriteChar ( Round ( ord ( 'O' ) - 0.5 ) );
  WriteChar ( Round ( - ord ( 'K' ) + 0.5 ) );
  writeln;
end.
