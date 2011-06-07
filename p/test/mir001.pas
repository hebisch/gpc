program SieveProgram (Output);
        {Sieve of Eratosthenes for finding prime numbers}
        {Stresses problems with sets}
        {Warning: set --setlimit to maxN+1 at least!!!!!!!!!!}
        {Written by Mirsad Todorovac, 2001}

const maxN = 255;

var
  i, j, k     : 0 .. maxN;
  Sieve       : set of 0 .. maxN;
  Ok, Divided : Boolean;

begin

  Ok := True;

  for i := 1 to maxN do  {initialize sieve}
    begin
      Sieve := Sieve + [i];
      if not (i in Sieve) then
        begin
          WriteLn ('Failed: ', i, ' not in SET after adding!');
          Ok := False;
        end
    end;

  for i := 2 to maxN do
    begin
      if i in Sieve then
        for k := i + 1 to maxN do
          if (k mod i = 0) and (k in Sieve) then
            begin
              Sieve := Sieve - [k];
              if k in Sieve then
                begin
                  WriteLn ('Failed: ', k, ' in SET after deletion!');
                  Ok := False;
                end
            end
    end;

  for i := 2 to maxN do
    if i in Sieve then
      begin
        { writeln('Checking if really prime: ', i); }
        for j := 2 to i - 1 do
          if i mod j = 0 then
            begin
              WriteLn ('Failed: ', i, 'in Sieve and', i,' % ', j, ' = 0.');
              Ok := False;
            end
      end
    else
      { now we know that i is not in Sieve, so it shouldn't be prime! }
      begin
        Divided := False;
        for j := 2 to i - 1 do
          if i mod j = 0 then Divided := True;
        if not Divided then
          begin
            WriteLn ('Failed: ', i, 'prime and not in Sieve.');
            Ok := False;
          end
      end;

  if Ok then WriteLn ('OK')

end.
