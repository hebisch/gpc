program Markus9;

type
  a = object
      constructor c;
    protected
      procedure p; virtual;
  end;

  b = object (a)
    public
      procedure p; virtual;
  end;

constructor a.c;
begin
end;

procedure a.p;
begin
  WriteLn ('failed')
end;

procedure b.p;
begin
  WriteLn ('OK')
end;

var
  v: b;

begin
  v.p
end.
