unit fjf218v;

interface

uses fjf218u;

type
  y = object (e)
    jc : pil;
    constructor Init (ajc : pil);
    destructor Done; virtual;
  end;

  py = ^y;

implementation

constructor y.Init (ajc : pil);
begin
  jc := ajc
end;

destructor y.Done;
begin
  dil (jc)
end;

end.
