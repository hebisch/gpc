{ Test of the TFDD unit. Very similar to TFDDDemo. }

program TFDDTest;

uses TFDD;

var
  LogFile, BothFiles: Text;
  s: String (100);

begin
  Rewrite (LogFile);
  MultiFileWrite (BothFiles, Output, LogFile);
  WriteLn ('This line appears only on standard output.');
  WriteLn (Output, 'This line as well.');
  WriteLn (LogFile, 'This line appears only in the log file.');
  WriteLn (BothFiles, 'But this line and the following one appear both on standard output');
  WriteLn (BothFiles, 'and in the log file, with just one `WriteLn''.');
  WriteLn;
  WriteLn ('Dumping the log file:');
  Reset (LogFile);
  while not EOF (LogFile) do
    begin
      ReadLn (LogFile, s);
      WriteLn (s)
    end
end.
