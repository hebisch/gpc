{ FLAG --extended-pascal }

program fjf784c;
var i: Integer;
begin
  for (i) in [1] do; (* WRONG - violation of 6.8.3.10 of ISO 7185 *)
end.
