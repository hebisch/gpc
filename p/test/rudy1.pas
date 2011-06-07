PROGRAM rudy1(input, output);

TYPE
  RealVectorT(b,e:integer)         =ARRAY[b..e]   OF Real;
  RealMatrixT(br,er,bc,ec:integer) =ARRAY[br..er] OF RealVectorT(bc,ec);

VAR x:RealMatrixT(1,5,1,5);

BEGIN
   x[1,1]:=42;
  { error: test.p: In function `pascal_main_program':
           test.p:10: subscripted object is not an array or string }
   if x[1][1] = 42 then WriteLn ('OK') else WriteLn ('failed');
  { this is O.K. }
END.
