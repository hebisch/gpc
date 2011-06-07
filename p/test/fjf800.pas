program Fjf800;

type
  t = record f: Integer end;
  u = record f: Real end value (0);

var
  v, w, x: t;
  p, q, r: u;
  a, b, c: Integer value 1;
  aO, bO, cO: t;
  aB, bB, cB: Boolean;
  aM: Boolean;
  bM: Integer;
  cM: set of Byte;

{$define OPS
OP (and,)
OP (and_then,B)
OP (as,O)
OP (div,)
OP (in,M)
OP (is,O)
OP (mod,)
OP (or,)
OP (or_else,B)
OP (pow,)
OP (shl,)
OP (shr,)
OP (xor,)
OP (all,O)
OP (bindable,O)
OP (name,O)
OP (Break,O)
OP (Cardinal,O)
OP (EQ,O)
OP (Fjf800,O)
OP (Foo,O)
OP (Halt,O)
OP (Inc,O)
OP (InitFDR,O)
OP (Input,O)
OP (Low,O)
OP (Move,O)
OP (Null,O)
OP (Pi,O)
OP (Reset,O)
OP (Sin,O)
OP (Return,O)
OP (Write,O)
}

{$define OP(SYMBOL, SUFFIX)
operator SYMBOL (a, b: t) c: t;
begin
  c.f := a.f + b.f
end;

operator SYMBOL (a, b: u) c: u;
begin
  c.f := a.f + b.f
end;
}

OPS

{$undef OP}

begin
  {$define OP(SYMBOL, SUFFIX)
  v := w SYMBOL x;
  p := q SYMBOL r;
  a##SUFFIX := b##SUFFIX SYMBOL c##SUFFIX;
  }
  OPS
  WriteLn ('OK')
end.
