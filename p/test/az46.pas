program az46(output);
(* FLAG --classic-pascal *)
begin
  writeln('failed: ',round(1)) (* WRONG - parameter of "round" should be
                                  of real-type *)
end.
