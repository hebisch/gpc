program fjf738g(output);
(* FLAG --classic-pascal *)
begin
  case 2 of
    1 .. 3: WriteLn ('failed 1')  { WRONG }
  end;
  WriteLn ('failed')
end.
