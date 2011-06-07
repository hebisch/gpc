module fjf864m;

export fjf864m = all;

type
  TString = String (10);

  o = object
    a: TString;
    procedure p;
  protected
    b: TString;
    procedure q;
  public
    c: TString;
    procedure r;
  private
    d: TString;
    procedure s;
  published
    e: TString;
    procedure t;
  end;

  oo = object (o)
    procedure u;
  end;

end;

procedure o.p;
begin
  d := e
end;

procedure o.q;
begin
  WriteLn (b)
end;

procedure o.r;
begin
  c := d[1]
end;

procedure o.s;
begin
  c := b[2]
end;

procedure o.t;
begin
  WriteLn (c, a)
end;

procedure oo.u;

  procedure j;
  begin
    p;
    r
  end;

begin
  d := 'X';
  b := 'YO';
  e := 'KK';
  j;
  a := c;
  s;
  t;
  if False then q
end;

end.
