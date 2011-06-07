{$borland-pascal}

program fjf1018d (Output);

const
  s = 'OK';

procedure p;
const s = 'failed';
begin
  WriteLn (fjf1018d.s)
end;

begin
  p
end.
