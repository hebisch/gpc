{$borland-pascal}

unit fjf1018w;

interface

const
  s = 'OK';

procedure p;

implementation

procedure p;
const s = 'failed';
begin
  WriteLn (fjf1018w.s)
end;

end.
