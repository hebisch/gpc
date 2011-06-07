{$R-}

program sam2(output);

var std: set of 1..100;
    x: Char;
    ste: set of 1..31;
    y: Char;

begin
   x:= 'O';
   y:= 'K';
   std := [1, 2, 5, 7, 10, 32..100 ];
   ste := std;
   writeln ( x, y );
end.
