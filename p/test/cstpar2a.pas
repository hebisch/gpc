Program CstPar2a;

Var
  K: String ( 10 ) value 'ABC';


Procedure OK ( protected Var S: String );
begin { OK }
  S:= 'XYZ';  { WRONG }
end { OK };


begin
  WriteLn ('failed');
end.
