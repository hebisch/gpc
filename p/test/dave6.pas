program dave6(output);
  type
    array_options = packed array [5..7] of 0..7;
  const
    imn = array_options [5 : 0 ; 6 : 1; 7 : 2];

begin
  if imn[6] = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
