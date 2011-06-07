program az11(output);
(* FLAG --classic-pascal *)
var a:record
        case b:boolean of
          true,false:()
      end;
procedure p(var x:boolean);
begin
end;
begin
  p(a.b); (* WRONG - violation of 6.6.3.3 of ISO 7185 *)
  writeln('failed')
end.
