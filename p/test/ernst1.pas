PROGRAM testsubrange;
var
    i: ShortInt;                  {signed 16 bit integer}
    j: SizeType;                  {unsigned 32 bit word}
    point : record x,y: array [1 .. 8] of Byte end; {takes 16 bytes}
begin
    i:= 3658;
    j:= 16;
    if (i * j = 58528) and (i * SizeOf(point) = 58528) then
      writeln ('OK')
    else
      begin
        writeln ('failed:');
        writeln ('result1 = ', i*j);             {58528, OK}
        writeln ('result2 = ', i*SizeOf(point)); {-7008, wrong}
      end
end.
