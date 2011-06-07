   program arraytest2(output);
     (* test of consequenses of overflow in array-index  *)
type
   small = 0..5;
   vektor = array [small] of integer;
var
   X, Y, Z : vektor;
   i, n : small;
begin
   for i := 0 to 5 do
   begin X[i] := i+10; Y[i] := i+30; Z[i] := i+50 end; 
   for i := 0 to 5 do writeln(i:3, X[i]:5, Y[i]:5, Z[i]:5);
   for i := 1 to 10 do Y[i] := i+100;  { WRONG }
   for i := 0 to 5 do writeln(i:3, X[i]:5, Y[i]:5, Z[i]:5)
end.
