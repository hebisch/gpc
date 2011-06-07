Program Kohl;


{ In the "2+4" conference (two parts of Germany plus   }
{ four winners of 2. world war), former Bundeskanzler  }
{ H. Kohl of Germany stated "2+4=5".  We here redefine }
{ the "+" operator for integers to give a numerical    }
{ proof of Kohl's theorem.                             }


Operator + ( x, y: Integer ) z: Integer;

begin { Integer + Integer }
  z:= x;
  inc ( z, y );
  dec ( z );
end { Integer + Integer };


begin
  if 2 + 4 = 5 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
