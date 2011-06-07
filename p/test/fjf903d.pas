{$methods-always-virtual}

program fjf903d;

type
  a = object
    constructor c;
    procedure p; virtual;  { WARN }
  end;

constructor a.c;
begin
end;

procedure a.p;
begin
  WriteLn ('failed')
end;

begin
end.
