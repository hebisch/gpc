Program JanJaap3a;


Type
  MyObj = object
    OKstr: String ( 2 );
    myself: ^Humpta;
  end { MyObj };

  Humpta = MyObj;  { Naja ... }


Var
  M: MyObj;


begin
  M.myself:= @M;
  M.myself^.OKstr:= 'OK';
  writeln ( M.OKstr );
end.
