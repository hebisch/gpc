Program ProcParm1;


Function MyOFunc: Char;

begin { MyOFunc }
  MyOFunc:= 'O';
end { MyOFunc };


Procedure MyKProc ( Var Ch: Char );

begin { MyKProc }
  Ch:= 'K';
end { MyKProc };


Procedure WriteOut ( Function OFunc: Char; Procedure KProc ( Var Ch: Char ) );

Var
  K: Char;

begin { WriteOut }
  KProc ( K );
  writeln ( OFunc, K );
end { WriteOut };


begin
  WriteOut ( MyOFunc, MyKProc );
end.
