program sets16b(output);

{$setlimit=1024}

   type
     Str = packed set of 1..1000;
     sss = packed set of 1..100;

   var
     v0 : Str;
     ok, ok0: boolean;
     gs: Str;
     aa1 : packed set of 1..2;
     aa2 : packed set of 1..10;
   procedure Doit( const var s: Str; p : pointer);
   begin
     if ((@s <> p) and (p <> nil)) or (s <> v0) then begin
       ok := false;
       ok0 := false;
     end else
       ok0 := true;
   end;
   function fiuu : sss;
   begin
     fiuu := [1..2];
   end;

{$define do_tst(x, k) v0 := x;  Doit(x, k);
                    if not ok0 then writeln('failed: ', #x); }
{$define do_tstr(x) do_tst(x, @x) }
{$define do_tstc(x) do_tst(x, nil) }

begin
   ok := true;
   do_tstc([1..2])
   do_tstc([1..2] + [10])
   do_tstc(Str[1..2])
   do_tstc(sss[1..2])
   do_tstc(fiuu)
   do_tstr( gs)
   do_tstc( aa1)
   do_tstc( aa2)
   if ok then writeln('OK')
end.

