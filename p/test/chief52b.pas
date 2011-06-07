{$borland-pascal}

program Chief52b;

type
  a = object
    procedure p;
  end;

  b = object (a)
    constructor c;
    procedure p; virtual;
  end;

procedure a.p;
begin
end;

constructor b.c;
begin
end;

procedure b.p;
begin
end;

begin
  WriteLn ('OK')
end.
