{ Added the `* ...', Frank 20030612 }

program sam2(output);

var std: set of 1..100;
    x: Char;
    ste: set of 1..31;
    y: Char;

begin
   x:= 'O';
   y:= 'K';
   std := [1, 2, 5, 7, 10, 32..100 ];
   ste := std * [Low (ste) .. High (ste)];
   writeln ( x, y );
end.
