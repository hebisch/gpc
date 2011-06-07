{ BP's silly behaviour, cf. fjf969[bc].pas }

{$W no-typed-const}

program fjf969a;

type
  t = record
    a, b: Integer
  end;
  u = array [1 .. 3] of Integer;

const
  a: t = (2, 3);
  b: u = (4, 5, 6);

begin
  a.a := 4;
  b[2] := 7;
  if (a.a = 4) and (a.b = 3) and (b[1] = 4) and (b[2] = 7) and (b[3] = 6) then WriteLn ('OK') else WriteLn ('failed')
end.
