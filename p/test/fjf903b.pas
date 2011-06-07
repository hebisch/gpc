{$methods-always-virtual}

program fjf903b;

type
  a = object
    constructor c;
    procedure p;
  end;

  pb = ^b;
  b = object (a)
    procedure p;
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
  v: ^a;

begin
  v := New (pb);
  v^.p
end.
