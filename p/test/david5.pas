{ FLAG --extended-pascal --enable-keyword=external,name }

program david5 (Output);

procedure proc; external name 'proc';

begin
  WriteLn ('OK')
end.
