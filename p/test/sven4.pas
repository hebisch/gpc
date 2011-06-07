program str_arr;

  const
    MyStringsCount = 6;
  type
    Ident = string(20);

  var
    MyStrings : array [1..MyStringsCount] of Ident value [
      1:'EXPORT'; 2:'IMPLEMENTATION'; 3:'IMPORT';
      4:'INTERFACE'; 5:'MODULE'; 6:'OK'];

begin
  writeln ( MyStrings [ 6 ] );
end.
