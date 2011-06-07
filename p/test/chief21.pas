program setbug;

type chset=set of char;

procedure x(Const b:chset);
begin      {^^^^ <-- this is the problem!}
  if b = [ ';' ] then
    write ( 'O' )
  else if b = [ '/' ] then
    writeln ( 'K' );
end;

procedure y(b:chset);
begin
end;

Const
b:chset=[';','|'];
c = '/';

begin
  y ([';']);
  x ([';']); {GPC rejects this}

  y (b);
  x(b);

  y ([c]);
  x([c]); {GPC rejects this}
end.
