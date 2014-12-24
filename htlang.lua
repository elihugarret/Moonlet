 --Usage example
 
 a = {
    beat = 'x*a-ao- *~  x* # ; - x* ',
   breik = '-  &x o- * o x ; -a bw',
    cool = ';1;2*1-m 2;  M * o ; x# ',
    otro = 'x *  x o -    ',
    satt = '|x*|d*z|x*|c*y'
    }
---------------------------------------------------------
seq
{
  P = sound(a.beat),
  e = 1,
  l = 1,
  V = sound(a.breik),
  R = 1,
  L = 1,
  T = 230,
  g = aX(1,1,100,-1,.1),
  u = aX(1,1,100,-1,.1),
  s = 24,
  c = 24,
}
