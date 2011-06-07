{$W no-object-assignment}

program fjf884t;

type
  a = object
    c: Integer;
    constructor q;
  end;

  b = object (a)
    d: Integer;
  end;

constructor a.q;
begin
end;

var
  q: a;
  r: b;

procedure w (var t: a);
begin
  {$local W-} t := r {$endlocal}
end;

begin
  q.q;
  r.q;
  w (q);
  if (TypeOf (q) = TypeOf (a)) and (TypeOf (r) = TypeOf (b)) then WriteLn ('OK') else WriteLn ('failed')
end.
