program fjf859;

const
  Bar = 3;

type
  a = object
    constructor a;
    procedure p; virtual 42;  { GPC currently ignores the value of the index
                                which makes no semantic difference. }
    procedure q; virtual 3 * Bar + Sqr (99);
  end;

constructor a.a;
begin
end;

procedure a.p;
begin
  Write ('O')
end;

procedure a.q;
begin
  WriteLn ('K')
end;

var
  v: a;

begin
  v.p;
  v.q
end.
