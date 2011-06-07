program fjf850h;

type
  a = object
    constructor c;
    function f: Integer; virtual;
  end;

  aa = object (a)
    function f = r: Integer; virtual;  { WRONG }
  end;

constructor a.c;
begin
end;

function a.f: Integer;
begin
  f := 42
end;

function aa.f = r: Integer;
begin
  r := 42
end;

begin
end.
