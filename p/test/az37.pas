(*
az37.pas: In main program:
az37.pas:3: ISO Pascal requires an entire `for' variable
az37.pas:3: invalid operands to binary <=
az37.pas:3: invalid lvalue in assignment
az37.pas:3: Internal compiler error in `do_abort', at toplev.c:2301
*)
program az37(output);
begin
  for char:=1 to 1 do; (* WRONG *)
  writeln('failed')
end.
