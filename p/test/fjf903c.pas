{$mac-pascal}

program fjf903c;

type
  {$local W-}
  a = object
    procedure p;
  end;

  b = object (a)
    procedure p; override;
  end;
  {$endlocal}

procedure a.p;
begin
  WriteLn ('failed')
end;

procedure b.p;
begin
  WriteLn ('OK')
end;

var
  v: a;

begin
  v := New (b);
  v.p
end.
