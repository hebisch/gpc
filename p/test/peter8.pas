program peter8(output);

type
    Str1 = String(1000);
    Str2 = packed array [1..1000] of char;
    Str3 = array [1..1000] of char;
    past(i : integer) = packed array [1..i] of char;
    Str4 = past(1000);
    past5 = past(5);
    ast(i : integer) = array [1..i] of char;
    Str5 = ast(1000);
    ast4 = ast(4);
    cs(i : integer) = char;
    cs5 = cs(5);
    
    s10 = packed array [1..10] of char;

var
    v1, v6, v7, v8, v9 : Str1;
    v2, v4 : Str2;
    v3, v5 : Str3;
    ok, ok0: boolean;
    gs1: Str1 value 'gs1';
    gs2: Str2 value 'gs2';
    gs3: Str3 value 'gs3';
    gs4: Str4 value 'gs4';
    gs5: Str5 value 'gs5';
    a : char value 'a';
    as : cs5 value 's';
    a1 : packed array [1..2] of char value 'a1';
    an : array [1..2] of char value 'an';
    a2 : s10 value 'a2';
    ss : String(100) value 'ss';
    sav1 : ast(10) value 'sav1';
    sav2 : ast4 value 'sav2';
    spav : past5 value 'spav';

{
procedure Doit6 (s : String; p : pointer);
begin
    if ((@s <> p) and (p <> nil)) or (s <> v0) then begin
        ok := false;
        ok0 := false;
    end else
        ok0 := true;
end;
}
{$define def_doit(m, n, i)
procedure Doit##i##m (n s : Str##i; p : pointer);
begin
    if ((@s <> p) and (p <> nil)) or (s <> v##i) then begin
        ok := false;
        ok0 := false;
    end else
        ok0 := true;
end;
}
{$define def_doits(i)
def_doit(v, , i)
def_doit(c, const, i)
def_doit(cv, const var, i)
}

{$define def_f(i)
def_doits(i) 
function f##i : Str##i;
begin
  f##i := 'Str' #i
end;
}
{$define Str6 String}
{$define Str7 array[l..h:integer] of char}
{$define Str8 packed array[l..h:integer] of char}
{$define Str9 array of char}
def_doits(6)
def_doits(7)
def_doits(8)
def_doits(9)
def_f(1)
def_f(2)
def_f(3)
def_f(4)
def_f(5)

function fc: char;
begin
  fc := 'f'
end;
function fcs: cs5;
begin
  fcs := 's'
end;

function fs10: s10;
begin
  fs10 := 'fs10'
end;


{$define do_tst(m, i, x, k) v##i := x;  Doit##i##m(x, k);
                    if not ok0 then writeln('failed: ', #x); }
{$define do_tstm(i, x, k) 
do_tst(v, i, x, k)
do_tst(c, i, x, k)
do_tst(cv, i, x, k)
}
{$define do_tstn(i, x) do_tstm(i, x, nil)}
{$define do_tstr(i, x) 
do_tst(c, i, x, @x)
do_tst(cv, i, x, @x)
}
{$define do_tstc0(x) 
do_tstn(1, x) 
do_tstn(2, x)
do_tstn(3, x)
do_tstn(4, x)
do_tstn(5, x)
do_tstn(6, x)
}
{$define do_tstc1(x)
do_tstn(7, x)
do_tstn(8, x)
do_tstn(9, x)
}
{$define do_tstc(x)
do_tstc0(x)
do_tstc1(x)
}

begin
   ok := true;

   do_tstc ('c');
   do_tstc ('cstr');
   do_tstc (ast4[1 : 'a'; 2 : 's'; 3 : 't'; 4 : '4']);
   do_tstc (past5[1 : 'p'; 2: 'a'; 3 : 's'; 4 : 't'; 5 : '5']);
   do_tstc (gs1);
   do_tstc (gs2);
   do_tstc (gs3);
   do_tstc (gs4);
   do_tstc (gs5);
   do_tstc (a);
   do_tstc (as);
   do_tstc (a1);
   do_tstc (an);
   do_tstc (a2); 
   do_tstc (sav1);
   do_tstc (sav2);
   do_tstc (spav);
   do_tstc (ss);

   do_tstc (f1);
   do_tstc (f2);
   do_tstc (f3);
   do_tstc (f4);
   do_tstc (f5); 

   do_tstc (fc);
   do_tstc (fcs);
   do_tstc (fs10);

   do_tstr (1, gs1);
   do_tstr (2, gs2);
   do_tstr (3, gs3);
   do_tstr (4, gs4);
   do_tstr (5, gs5);
   do_tstr (6, gs1);
   do_tstr (7, gs2);
   do_tstr (7, gs3);
   do_tstr (8, gs2);
   do_tstr (8, gs3);
   do_tstr (9, gs2);
   do_tstr (9, gs3);

  if ok then writeln ('OK')
end.

