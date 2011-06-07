program az5(output);
(* FLAG --classic-pascal *)
var r:record
        case boolean of
          false..true:() (* WRONG - violation of 6.8.3.5 of ISO 7185 *)
      end;
begin
  writeln('failed')
end.
