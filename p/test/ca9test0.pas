Unit CA9Test0;

Interface

Type
  Natural = 1..MaxInt;

Procedure WriteOK ( Var x: array [ K..O: Natural ] of Char );

Implementation

Procedure WriteOK ( Var x: array [ K..O: Natural ] of Char ); {$local W-} external; {$endlocal}

end.
