program fjf775b;

type
  a = object
    procedure o (a, b: Char; c: Integer);
  end;

  b = object (a)
    procedure p;
  end;

procedure a.o (a, b: Char; c: Integer);
begin
  if c = 42 then WriteLn (a, b) else WriteLn ('failed')
end;

procedure b.p;

  procedure c;
  const
    b = 'O';
    o = 'K';
    a = 42;
  begin
    inherited o (b, o, a)
  end;

begin
  c
end;

var
  v: b;

begin
  v.p
end.
