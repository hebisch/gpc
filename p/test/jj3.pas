Program JanJaap3;


Type
  MyObj = object
    OKstr: String ( 2 );
    Procedure OK ( Var O: MyObj );
  end { MyObj };


Var
  M: MyObj;


Procedure MyObj.OK ( Var O: MyObj );

begin { MyObj.OK }
  writeln ( O.OKstr );
end { MyObj.OK };


begin
  M.OKstr:= 'OK';
  M.OK ( M );
end.
