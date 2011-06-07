program TestSize;

type tR = object
              constructor init;
              function    Size: integer;  virtual;
              destructor  fini;
           end;

constructor tR.init;
begin
end;

function tR.Size: integer;
begin
    Size := 1
end;

destructor tR.fini;
begin
end;

begin
  WriteLn ('OK')
end.
