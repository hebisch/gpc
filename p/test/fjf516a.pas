{ FLAG -O0 }

program fjf516a;

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

{$define EQ(a,b) T(a=b); F(a>b); T(a>=b); F(a<b); T(a<=b); F(a<>b)}
{$define GT(a,b) F(a=b); T(a>b); T(a>=b); F(a<b); F(a<=b); T(a<>b)}
{$define LT(a,b) F(a=b); F(a>b); F(a>=b); T(a<b); T(a<=b); T(a<>b)}

{$W-}

begin
  EQ('',''); LT('','x'); GT('x',''); GT('c','b');
  EQ(q,q); EQ(r,r); LT(q,r); EQ(q,''); EQ(r,'r'); LT(q,'r'); GT(r,'');
  EQ(s,s); EQ(u,u); EQ(v,v); EQ(w,w); EQ(s,u); EQ(v,w); LT(s,v); LT(s,w);
  EQ(s,q); LT(s,r); EQ(s,''); LT(s,'x');
  GT(v,q); GT(v,r); GT(v,''); LT(v,'x');
  EQ(c,c); EQ(d,d); LT(c,d);
  GT(c,q); LT(c,r); GT(c,''); LT(c,'x'); GT(c,s); LT(c,v);
  GT(d,q); LT(d,r); GT(d,''); LT(d,'x'); GT(d,s); LT(d,v);
  EQ(g,g); EQ(h,h); EQ(i,i); EQ(j,j); EQ(g,h); LT(i,j); LT(g,i); LT(g,j);
  EQ(g,q); LT(g,r); EQ(g,''); LT(g,'x');
  GT(i,q); LT(i,r); GT(i,''); LT(i,'x');
  EQ(g,s); LT(g,v); LT(g,w);
  GT(i,s); LT(i,v); LT(i,w);
  GT(j,s); LT(j,v); LT(j,w);
  WriteLn ('OK')
end.
