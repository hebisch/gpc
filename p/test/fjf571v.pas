unit fjf571v;

interface

type
  o = object
    procedure a (procedure aaa);  { This "hides" the global procedure of the same name! }
  end;

procedure aaa;

implementation

procedure o.a (procedure aaa);
begin
end;

procedure aaa;
begin
  WriteLn ('OK')
end;

end.
