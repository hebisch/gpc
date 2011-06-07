program fjf750f;

type
  Sch (I: Integer) = I .. I + 2;
  T (J: Integer) = Sch (J);
  U (K: Integer) = T (K);
  S = U (2);

var
  A: S;

begin
  if (Low (A) = 2) and (High (A) = 4) and
     (Low (S) = 2) and (High (S) = 4) then WriteLn ('OK') else WriteLn ('failed')
end.
