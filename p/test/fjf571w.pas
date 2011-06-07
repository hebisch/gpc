unit fjf571w;

interface

type
  o = object
    procedure a (aaa: Integer);  { This "hides" the global procedure of the same name! }
  end;

procedure aaa;

implementation

procedure o.a (aaa: Integer);
begin
end;

procedure aaa;
begin
  WriteLn ('OK')
end;

end.
