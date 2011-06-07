program BufferedInput (Output, F);

var
  F: bindable Text;
  Buffer: String (100);

begin
  Reset (F, '');
{$extended-pascal}
  while not EOF (F) do begin
    while not EOLn (F) do begin
      Read (F, Buffer);
      WriteLn ('read: `', Buffer, '''')
    end;
    WriteLn ('(end of line)');
    ReadLn (F)
  end;
  WriteLn ('(end of file)')
end.
