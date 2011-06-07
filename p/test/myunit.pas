Unit MyUnit;

Interface

Const
  OKlength = 2;

Type
  OKarray = array [ 1..OKlength ] of Char;

Var
  OKvar: OKarray;
  OKvari: Char value 'x';

Procedure OK;

Implementation

Procedure OK;

Var
  i: Integer;

begin { OK }
  for i:= 1 to OKlength do
    write ( OKvar [ i ] );
  writeln;
end { OK };

end.
