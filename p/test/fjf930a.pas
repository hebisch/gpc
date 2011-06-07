{ Modification of scott1.pas for non-standard Pascal modes }

program test(output);

var f: text;
    c: char;

begin

   rewrite(f);
   writeln(f, 'how now');
   writeln(f, 'brown cow');
   reset(f);
   write('''');
   while not eof(f) do begin

      if eoln(f) then write('<eoln>');
      read(f, c);
      write(c)

   end;
   write('''');
   writeln(' s/b ''how now<eoln> brown cow<eoln> ''');
   rewrite(f);
   writeln(f, 'too much');
   write(f, 'too soon');
   reset(f);
   write('''');
   while not eof(f) do begin

      if eoln(f) then write('<eoln>');
      read(f, c);
      write(c)

   end;
   write('''');
   writeln(' s/b ''too much<eoln> too soon''');

end.
