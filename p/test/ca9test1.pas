Unit CA9Test1;

Interface

uses
  CA9Test0;

Procedure WriteOK ( Var x: array [ K..O: Natural ] of Char );
Procedure Test;

Implementation

Procedure WriteOK ( Var x: array [ K..O: Natural ] of Char );

begin { WriteOK }
  writeln ( chr ( O ), chr ( K ) );
end { WriteOK };

Procedure Test;

Var
  OK: array [ 75..79 ] of Char;

begin { Test }
  WriteOK ( OK );
end { Test };

end.
