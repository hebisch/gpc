   program arraytest(output);
     (* test of overflow in subrange and array-index.
        gpc allows the following program,  pc does not  *)

uses GPC;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

type
   small = 0..100;
   vektor = array [small] of Integer;
var
   x : vektor;
   A : array [0..5, 0..5] of Integer;
   i, n : small;
begin
  AtExit (ExpectError);
   n := 98;
   for i := 1 to 7 do
   begin n := n + 1; x[n] := n+6;
         A[i,n] := i + n; WriteLn(n:4, x[n]:4, A[i,n]:5) end
end.
