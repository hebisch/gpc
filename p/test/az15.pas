program az15(output);
(* FLAG --classic-pascal *)
begin
  write('failed');
  writeln('1':0,'22':0,3:0) (* WRONG - violation of 6.9.3.1 of ISO 7185 *)
                            (* Besides, writing "13" seems inconsistent *)
end.
