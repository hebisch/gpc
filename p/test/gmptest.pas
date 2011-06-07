{ COMPILE-CMD: gmp.cmp }

{ Test of the GMP unit. (Very similar to the Pi, Power, RealPower,
  Fibonacci and Factorial demos merged.) }

program GMPTest;

uses GPC, GMP;

var
  a, e, d: MedCard;
  f, p_r, a_r, e_r: mpf_t;
  BaseStr, ExpStr, TempStr: TString;
  OK, RootFlag: Boolean;
  ex: mp_exp_t;
  s: CString;
  t1, t2, t, p, r: mpz_t;
  n, i: Integer;
  r1, r2, r3: Real;

procedure Error (const Msg : String);
begin
  WriteLn ('Error while computing ', Msg);
  OK := False
end;

procedure mpf_ReadStr (const s : String; var Dest : mpf_t);
begin
  mpf_init (Dest);
  if mpf_set_str (Dest, s, 10) <> 0 then
    begin
      WriteLn ('Invalid numeric format.');
      RunError
    end
end;

procedure x(i:Integer);external name 'free';
begin
  OK := True;
  d := 200;
  mpf_set_default_prec (Round (d * Ln (10) / Ln (2)) + 16);
  mpf_init (f);
  mpf_pi (f);
  s := mpf_get_str (nil, ex, 10, d, f);
  if (ex <> 1) or (CString2String (s) <> '3141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930382') then Error ('pi');
  Dispose (s);
  mpf_clear (f);
  a := 42;
  e := 99;
  mpz_init (p);
  mpz_ui_pow_ui (p, a, e);
  s := mpz_get_str (nil, 10, p);
  if CString2String (s) <> '50312946214556208012620096321978904564259007874132858601535188914084879044654708992576548993622662170762602743998384737973325441742527281540736914159145874096128' then Error ('integer power');
  Dispose (s);
  mpz_clear (p);
  BaseStr := '2.3e1';
  ExpStr := '5.7';
  d := 128;
  mpf_set_default_prec (Round (d * Ln (10) / Ln (2)) + 64);
  mpf_ReadStr (BaseStr, a_r);
  RootFlag := Copy (ExpStr, 1, 2) = '1/';
  TempStr := ExpStr;
  if RootFlag then Delete (TempStr, 1, 2);
  mpf_ReadStr (TempStr, e_r);
  if RootFlag then mpf_ui_div (e_r, 1, e_r);
  mpf_init (p_r);
  mpf_pow (p_r, a_r, e_r);
  s := mpf_get_str (nil, ex, 10, d, p_r);
  if (ex <> 8) or (CString2String (s) <> '57789463855888747888070861266347833811505074790145323973686852397986522745256326763159091746070726450296186905854923842524148511') then Error ('real power #1');
  Dispose (s);
  mpf_clear (p_r);
  BaseStr := '3.5e7';
  ExpStr := '1/0.3';
  d := 128;
  mpf_set_default_prec (Round (d * Ln (10) / Ln (2)) + 64);
  mpf_ReadStr (BaseStr, a_r);
  RootFlag := Copy (ExpStr, 1, 2) = '1/';
  TempStr := ExpStr;
  if RootFlag then Delete (TempStr, 1, 2);
  mpf_ReadStr (TempStr, e_r);
  if RootFlag then mpf_ui_div (e_r, 1, e_r);
  mpf_init (p_r);
  mpf_pow (p_r, a_r, e_r);
  s := mpf_get_str (nil, ex, 10, d, p_r);
  if (ex <> 26) or (CString2String (s) <> '14024696804933578459763859594007978137824047246102058701726051462472046691186746163247551989870355816714192605199888481942907503') then Error ('real power #2');
  Dispose (s);
  mpf_clear (p_r);
  n := 1000;
  mpz_init_set_si (t1, 1);
  mpz_init_set_si (t2, 1);
  for i := 3 to n do
    begin
      mpz_init (t);
      mpz_add (t, t1, t2);
      mpz_clear (t1);
      t1 := t2;
      t2 := t
    end;
  s := mpz_get_str (nil, 10, t2);
  if CString2String (s) <> '43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875' then Error ('fibonacci number');
  Dispose (s);
  mpz_clear (t1);
  mpz_clear (t2);
  n := 200;
  mpz_init (r);
  mpz_fac_ui (r, n);
  s := mpz_get_str (nil, 10, r);
  if CString2String (s) <> '788657867364790503552363213932185062295135977687173263294742533244359449963403342920304284011984623904177212138919638830257642790242637105061926624952829931113462857270763317237396988943922445621451664240254033291864131227428294853277524242407573903240321257405579568660226031904170324062351700858796178922222789623703897374720000000000000000000000000000000000000000000000000' then Error ('factorial');
  Dispose (s);
  mpz_clear (r);
  mpf_init (f);
  mpf_init (p_r);
  for i := 1 to 100 do
    begin
      r1 := Exp ((i div 2) / 15) - 1;
      if Odd (i) then r1 := -r1;
      mpf_set_d (f, r1);
      mpf_sin (p_r, f);
      r2 := mpf_get_d (p_r);
      r3 := Sin (r1);
      if Abs (r2 - r3) > 1e-6 * Abs (r3) then Error ('sin ' + Integer2String (i));
      mpf_cos (p_r, f);
      r2 := mpf_get_d (p_r);
      r3 := Cos (r1);
      if Abs (r2 - r3) > 1e-6 * Abs (r3) then Error ('cos ' + Integer2String (i));
      mpf_arctan (p_r, f);
      r2 := mpf_get_d (p_r);
      r3 := ArcTan (r1);
      if Abs (r2 - r3) > 1e-6 * Abs (r3) then Error ('arctan ' + Integer2String (i))
    end;
  mpf_clear (f);
  mpf_clear (p_r);
  mpf_init_set_d (f, 2.1);
  if mpf_cmp_ui (f, 4) >= 0 then Error ('mpf_cmp_ui');
  if mpf_cmp_si (f, 4) >= 0 then Error ('mpf_cmp_si #1');
  if mpf_cmp_si (f, -4) <= 0 then Error ('mpf_cmp_si #2');
  mpf_clear (f);
  if OK then WriteLn ('OK')
end.
