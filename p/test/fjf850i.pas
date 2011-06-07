program fjf850i;

type
  a = object
    constructor c;
    function f = r: Integer; virtual;
  end;

  aa = object (a)
    function f: Integer; virtual;  { WRONG }
  end;

constructor a.c;
begin
end;

function a.f = r: Integer;
begin
  r := 42
end;

function aa.f = f: Integer;
begin
  f := 42
end;

begin
end.
