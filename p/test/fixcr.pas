program FixCR;

var
  s: String (20000);

begin
  while not EOF do
    begin
      Read (s);
      while (s <> '') and (s[Length (s)] = #13) do Delete (s, Length (s));
      Write (s);
      if not EOF and EOLn then
        begin
          ReadLn;
          WriteLn
        end
    end
end.
