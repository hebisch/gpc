unit fjf571u;

interface

type
  o = object
    procedure aaa;  { This "hides" the global procedure of the same name! }
  end;

procedure aaa;

implementation

procedure o.aaa;
begin
end;

procedure aaa;
begin
  WriteLn ('OK')
end;

end.
