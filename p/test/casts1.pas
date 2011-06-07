Program Test;

Type
  MyCast = packed record
    O, K: Char;
  end { MyCast };

Var
  x: Word attribute (Size = BitSizeOf (MyCast));

begin
  with MyCast ( x ) do
    begin
      O:= 'O';
      K:= 'K';
      writeln ( O, K );
    end { with };
end.
