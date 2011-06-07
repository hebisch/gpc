{ FLAG -O0 }

program fjf516b;

type
  TString = String (10);

const
  q = '';
  r = 'r';

var
  s, u: TString = '';
  v, w: TString = 'v';
  c: Char = 'c';
  d: Char = 'd';
  n: Integer = 0;

function g: TString;
begin
  g := ''
end;

function h: TString;
begin
  h := ''
end;

function i: TString;
begin
  i := 'i'
end;

function j: TString;
begin
  j := 'j'
end;

procedure T (a: Boolean);
begin
  Inc (n);
  if not a then
    begin
      WriteLn ('failed ', n);
      Halt
    end
end;

procedure F (a: Boolean);
begin
  Inc (n);
  if a then
    begin
      WriteLn ('failed ', n);
      Halt
    end
end;

{$W-}

{$define EQ(a,b) T(a=b); F(a>b); T(a>=b); F(a<b); T(a<=b); F(a<>b)}
{$define GT(a,b) F(a=b); T(a>b); T(a>=b); F(a<b); F(a<=b); T(a<>b)}
{$define LT(a,b) F(a=b); F(a>b); F(a>=b); T(a<b); T(a<=b); T(a<>b)}
{$define EQe(a,b) T(a=b); F(a>b); T(a<=b); F(a<>b)}
{$define GTe(a,b) F(a=b); T(a>b); F(a<=b); T(a<>b)}
{$define LTe(a,b) F(a=b); F(a>b); T(a<=b); T(a<>b)}
{$define LTee(a,b) F(a=b); F(a>=b); T(a<b); T(a<>b)}

begin
  EQ('',''); LTee('','x'); GTe('x',''); GT('c','b');
  EQ(q,q); EQ(r,r); GTe(r,q); EQe(q,''); EQ(r,'r'); LTee(q,'r'); GTe(r,'');
  EQ(s,s); EQ(u,u); EQ(v,v); EQ(w,w); EQ(s,u); EQ(v,w); LT(s,v); LT(s,w);
  EQe(s,q); LT(s,r); EQe(s,''); LT(s,'x');
  GTe(v,q); GT(v,r); GTe(v,''); LT(v,'x');
  EQ(c,c); EQ(d,d); LT(c,d);
  GTe(c,q); LT(c,r); GTe(c,''); LT(c,'x'); GT(c,s); LT(c,v);
  GTe(d,q); LT(d,r); GTe(d,''); LT(d,'x'); GT(d,s); LT(d,v);
  EQ(g,g); EQ(h,h); EQ(i,i); EQ(j,j); EQ(g,h); LT(i,j); LT(g,i); LT(g,j);
  EQe(g,q); LT(g,r); EQe(g,''); LT(g,'x');
  GTe(i,q); LT(i,r); GTe(i,''); LT(i,'x');
  EQ(g,s); LT(g,v); LT(g,w);
  GT(i,s); LT(i,v); LT(i,w);
  GT(j,s); LT(j,v); LT(j,w);
  WriteLn ('OK')
end.
