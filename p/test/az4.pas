program az4(output);
(* FLAG --classic-pascal *)
begin
  case 4 of
    2+2: (* WRONG - violation of 6.8.3.5 of ISO 7185 *)
  end;
  writeln('failed')
end.
