{$implicit-result}

Program RetVal;

Function O: Char;

begin { O }
  Result:= 'O';
end { O };

{$no-implicit-result}

Function K: Char;

Var
  Result: array [ 1..7 ] of Char;

begin { K }
  Result:= '....K..';
  K:= Result [ 5 ];
end { K };

begin
  writeln ( O, K );
end.
