{ Problem with identifier `Name' (cf. `external name' }

program fjf423;

const
  c : array [1 .. 2] of record
    Name, Name2 : String [1];
  end = ((Name : 'O'; Name2 : ''),
         (Name : ''; Name2 : 'K'));

begin
  WriteLn (c [1].Name, c [2].Name2)
end.
