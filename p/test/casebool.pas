Program CaseBool;

Function Answer: Integer;

begin { Answer }
  Answer:= 42;
end { Answer };

begin
  case Answer = 42 of
    true: writeln ( 'OK' );
    false: writeln ( 'failed' );
  end { case };
end.
