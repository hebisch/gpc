module BO4_20m interface;

export BO4_20m = all;

type
  o0 = object
    procedure Init;
  end;

  o = object (o0)
    procedure Init;
  end;

end.

module BO4_20m implementation;

procedure o0.Init;
begin
  WriteLn ('OK')
end;

procedure o.Init;
begin
  inherited Init
end;

end.
