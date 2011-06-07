   program arraytest2(output);
     (* test of consequenses of overflow in array-index  *)

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
   small = 0..5;
   vektor = array [small] of Integer;
var
   x, y, z : vektor;
   i : Integer;
begin
  AtExit (ExpectError);
   for i := 0 to 5 do
   begin x[i] := i+10; y[i] := i+30; z[i] := i+50 end;
{   for i := 0 to 5 do WriteLn(i:3, x[i]:5, y[i]:5, z[i]:5); }
   for i := 1 to 10 do y[i] := i+100;
   for i := 0 to 5 do WriteLn(i:3, x[i]:5, y[i]:5, z[i]:5)
end.
