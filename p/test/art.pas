program art(output);
  type
    as(i: integer) = array [0..i] of integer;
    art = record a: as(2) end;

  const
    imn = art [a:[0 : 0 ; 1 : 1; 2 : 2]];

begin
  if imn.a.i = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
