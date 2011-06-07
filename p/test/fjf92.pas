{ FLAG --nested-comments }

program fjf92;

{$define CHECKS
CHECK(1,1,Cardinal)
CHECK(2,LongInt(1),LongInt)
{ CHECK(3,Byte(200)+Byte(200),ShortWord) }
CHECK(3,Byte(200)+Byte(200),Integer)
CHECK(4,LongInt(1)+2,LongInt)
CHECK(5,$100000000,LongCard)
CHECK(6,50000,Cardinal)
CHECK(7,50000 div 200,Cardinal)
{ CHECK(8,50000 div Byte(200),Byte) }
CHECK(8,50000 div Byte(200),Integer)
CHECK(9,LongInt(1)+LongInt(2),LongInt)
CHECK(10,1+1,Integer)
CHECK(11,2,Integer)
}

{$define CHECK(n,val,typ) const const##n = val;}

CHECKS

{$undef CHECK}
{$define CHECK(n,val,typ)
 var var##n: type of const##n;
 if SizeOf(var##n) <> SizeOf(typ) then Fail(100+n,SizeOf(var##n),SizeOf(typ));
{ if SizeOf(val)      <> SizeOf(typ) then Fail(200+n,SizeOf(val),SizeOf(typ)); }
}

function foo(a,b:integer):integer; attribute (name = 'Foo');
begin
 foo:=100*a+b
end;

function bar(...):integer; external name 'Foo';

procedure fail(a,b,c:integer);
begin
  writeln('Failed ',a,' ',b,' ',c);
  halt(99)
end;

begin
 if bar(1,2)<>102 then fail(1,bar(1,2),102);
 if bar(integer(1),integer(2))<>102 then fail(2,bar(integer(1),integer(2)),102);

 { Rather pointless test, and maybe even wrong. Basically, the behaviour is undefined. }
 if not (bar(LongInt(1),LongInt(2)) in [1,100,102]) then fail(3,bar(LongInt(1),LongInt(2)),102);

 {$W-}
 CHECKS
 {$W+}
 writeln('OK')
end.
