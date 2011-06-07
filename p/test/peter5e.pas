{$mac-pascal}
program peter5e(output);

type
    obj = object
              procedure Destroy;
          end;

var dobj : obj;

procedure obj.Destroy;
begin
    dobj := self;
    dispose( dobj );
end;

var
    o: obj;
begin
    new(o);
    o.Destroy;
    WriteLn( 'OK' );
end.

