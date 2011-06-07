program fjf876;

{$define X ^"}
{$define Y ^'}

begin
  if (^ = Chr (Ord ('') xor 64))
    and (^% = Chr (Ord ('%') xor 64))
    and (^" = Chr (Ord ('"') xor 64))
    and (^' = Chr (Ord ('''') xor 64))
    and (^, = Chr (Ord (',') xor 64))
    and (^+ = Chr (Ord ('+') xor 64))
    and (^@ = Chr (Ord ('@') xor 64))
    and (^  = Chr (Ord (' ') xor 64))
    and (^_ = Chr (Ord ('_') xor 64))
    and (X = Chr (Ord ('"') xor 64))
    and (Y = Chr (Ord ('''') xor 64)) then WriteLn ('OK') else WriteLn ('failed')
end.
