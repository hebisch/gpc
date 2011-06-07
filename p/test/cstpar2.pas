Program CstPar2;

Var
  K: String ( 10 ) value 'ABC';


Procedure OK ( Const S: String );  { passed by reference }
begin { OK }
  S:= 'XYZ';  { WRONG }
end { OK };


begin
  WriteLn ('failed');
end.
