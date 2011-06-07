program prog(input,output);

{$L sam3m.pas }

var
   v1 :  array [1..10] of integer;

#if 1
procedure p1(a1 : array [lo .. hi : integer ] of integer ) ; external name 'p1'; { This fails }
#else
procedure p1(a1 : array [lo .. hi : integer ] of integer ) ; begin end; {This works }
#endif

begin
  p1(v1);
end.
