program fjf600b;

type
  t2 (d: Integer) = record
    a: Integer;
    b: record
         d: array [1 .. 8] of Byte;
       case e: Integer of
         0: (b: array [1 .. d] of Integer); { WARN }
         1: (c: array [1 .. d] of Integer);
       end;
  end;
begin
  WriteLn ('OK')
end.
