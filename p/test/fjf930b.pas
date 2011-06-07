program test(output);

var f: text;
    c: char;
    s: string (1);
    r, t: string (100);
begin
   rewrite(f);
   writeln(f, 'a');
   writeln(f, 'b');
   writeln(f);
   writeln(f);
   writeln(f);
   writeln(f);
   writeln(f, 'c');
   write(f, 'd');

{$define CHECK1(v, u, n)
   r := '';
   reset(f);
   while not eof(f) do
     begin
      if eoln(f) then
        begin
          readln (f);
          r := r + '#';
        end
      else if u then
        begin
          read (f, v);
          r := r + v
        end
      else
        begin
          r := r + f^;
          Get (f)
        end
     end;
   if r <> 'a#b#####c#d' then
     begin
       writeln ('failed ', n);
       Halt
     end;}

{$define CHECK2(v, u, n, e)
   r := '';
   reset(f);
   while not eof(f) do
     begin
      if eoln(f) then
        begin
          readln (f);
          r := r + '#';
        end;
      if u then
        begin
          read (f, v);
          r := r + v
        end
      else
        begin
          r := r + f^;
          Get (f)
        end
     end;
   if r <> e then
     begin
       writeln ('failed ', n);
       Halt
     end;}

   CHECK1 (c, True, 1);
   CHECK1 (s, True, 2);
   CHECK1 (t, True, 3);
   CHECK1 (c, False, 4);
   CHECK2 (c, True, 5, 'a#b# # #c#d'); {!}
   CHECK2 (s, True, 6, 'a#b#####c#d');
   CHECK2 (t, True, 7, 'a#b#####c#d');
   CHECK2 (c, False, 8, 'a#b# # #c#d'); {!}

   writeln ('OK')
end.
