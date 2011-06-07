program Out3 (Output);
(* FLAG --classic-pascal *)

var
  F: file of Char;

begin
  Rewrite (F);
  WriteLn (F); { WRONG - not a text file }
  WriteLn ('failed')
end.
