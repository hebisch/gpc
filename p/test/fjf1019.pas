program fjf1019 (Output);

var
  a, n: Integer = 0;

function f: Integer;
begin
  Inc (n);
  f := n
end;

procedure p1;
type t = Integer value f;
begin
end;

procedure p2;
type t = Integer value f;
var a: t;
begin
end;

procedure p3;
type t = Integer value f;
var a, b: t;
begin
end;

procedure p4;
type t = Integer value f;
var
  a: t;
  b: t;
begin
end;

procedure p5;
type t = Integer value f;
var
  a: t;
  b: Integer value f;
begin
end;

procedure p6;
type t = Integer value f;
var
  a: Integer value f;
  b: Integer value f;
begin
end;

procedure p7;
type t = Integer value f;
var
  a, b: Integer value f;
begin
end;

procedure c (t: Integer);
begin
  Inc (a);
  if n <> t then WriteLn ('failed ', a, ' ', n, ' ', t)
end;

begin
  p1; c (1);
  p2; c (2);
  p3; c (3);
  p4; c (4);
  p5; c (6);
  p6; c (9);
  p7; c (11);
  WriteLn ('OK')
end.
