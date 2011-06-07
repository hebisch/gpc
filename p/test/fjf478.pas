{$W-}

program fjf478;

var
  a : Real = 17.5;
  b : Integer = 18;

begin
  if (Re (42) = 42) and (Im (42) = 0) and
     (Re (41.9) = 41.9) and (Im (41.9) = 0) and
     (Re (a) = 17.5) and (Im (a) = 0) and
     (Re (b) = 18) and (Im (b) = 0) then WriteLn ('OK') else WriteLn ('failed')
end.
