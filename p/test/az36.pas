{$W-}
(*
d:\src\gcc-2.95.3-20010828\gcc\p\gpc-common.c:1390:build_pascal_binary_op: failed assertion `result'
az36.pas: In main program:
az36.pas:4: Internal compiler error.
*)
program az36(output);
begin
  if 0 in ([]*[1])
    then writeln('failed')
    else writeln('OK')
end.
