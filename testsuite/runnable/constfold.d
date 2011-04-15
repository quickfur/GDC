#! blah

static assert(__LINE__ == 3); // fails as __LINE__ is 2

import std.stdio;
import std.math;


/************************************/

static assert(-(1) == -1);
static assert(-(6i) == -6i);
static assert(-(1 + 6i) == -1 - 6i);

static assert(!27 == 0);
static assert(!0 == 1);
static assert(!6.2 == 0);
static assert(!0.0 == 1);
static assert(!3.7i == 0);
static assert(!0.0i == 1);
static assert(!(2+3.7i) == 0);
static assert(!(0+3.7i) == 0);
static assert(!(2+0.0i) == 0);
static assert(!(0+0.0i) == 1);

static assert(-6i + 2i == -4i);
static assert(6i - 1i == 5i);

static assert((3.6 + 7.2i) / (1 + 0i) == 3.6 + 7.2i);
static assert((3.6 + 7.2i) / (0.0 + 1i) == 7.2 - 3.6i);

static assert((6 % 4) == 2);
static assert((6u % 4u) == 2u);

static assert((cast(byte)0x109 >> 1) == 4);
static assert((cast(byte)-1 >> 1) == -1);
static assert((cast(ubyte)0x109 >> 1) == 4);

static assert((cast(short)0x10009 >> 1) == 4);
static assert((cast(short)-1 >> 1) == -1);
static assert((cast(ushort)0x10009 >> 1) == 4);

static assert((cast(long)0x1_0000_0000_0009 >> 1) == 0x8000_0000_0004);
static assert((cast(long)-1L >> 1) == -1);
static assert((cast(ulong)0x10009 >> 1) == 0x8004);

static assert((cast(byte)0x109 >>> 1) == 4);
static assert((cast(byte)-1 >>> 1) == int.max);
static assert((cast(ubyte)0x109 >>> 1) == 4);

static assert((cast(short)0x10009 >>> 1) == 4);
static assert((cast(short)-1 >>> 1) == int.max);
static assert((cast(ushort)0x10009 >>> 1) == 4);

static assert((cast(long)0x1_0000_0000_0009 >>> 1) == 0x8000_0000_0004);
static assert((cast(long)-1L >>> 1) == long.max);
static assert((cast(ulong)0x10009 >>> 1) == 0x8004);

static assert((3 ^ 5) == 6);

static assert((0 && 0) == 0);
static assert((0 && 5) == 0);
static assert((10 && 0) == 0);
static assert((58 && 10000) == 1);

static assert((0.0 && 0.0) == 0);
static assert((0.0 && 5.1) == 0);
static assert((10.0 && 0.0) == 0);
static assert((58.6 && 10000.7) == 1);

static assert((0 || 0) == 0);
static assert((0 || 5) == 1);
static assert((10 || 0) == 1);
static assert((58 || 10000) == 1);

static assert((0.0 || 0.0) == 0);
static assert((0.0 || 5.1) == 1);
static assert((10.0 || 0.0) == 1);
static assert((58.6 || 10000.7) == 1);

static assert((5 < 3) == 0);
static assert((5 < 5) == 0);
static assert((5 < 6) == 1);
static assert((5 <= 3) == 0);
static assert((5 <= 5) == 1);
static assert((5 <= 6) == 1);
static assert((5 > 3) == 1);
static assert((5 > 5) == 0);
static assert((5 > 6) == 0);
static assert((5 >= 3) == 1);
static assert((5 >= 5) == 1);
static assert((5 >= 6) == 0);
static assert((5 <>= 3) == 1);
static assert((5 <>= 5) == 1);
static assert((5 <>= 6) == 1);
static assert((5 <> 3) == 1);
static assert((5 <> 5) == 0);
static assert((5 <> 6) == 1);
static assert((5 !<>= 3) == 0);
static assert((5 !<>= 5) == 0);
static assert((5 !<>= 6) == 0);
static assert((5 !<> 3) == 0);
static assert((5 !<> 5) == 1);
static assert((5 !<> 6) == 0);
static assert((5 !<= 3) == 1);
static assert((5 !<= 5) == 0);
static assert((5 !<= 6) == 0);
static assert((5 !< 3) == 1);
static assert((5 !< 5) == 1);
static assert((5 !< 6) == 0);
static assert((5 !>= 3) == 0);
static assert((5 !>= 5) == 0);
static assert((5 !>= 6) == 1);
static assert((5 !> 3) == 0);
static assert((5 !> 5) == 1);
static assert((5 !> 6) == 1);

static assert((-5 < -3) == 1);
static assert((-5 < -5) == 0);
static assert((-5 < -6) == 0);
static assert((-5 <= -3) == 1);
static assert((-5 <= -5) == 1);
static assert((-5 <= -6) == 0);
static assert((-5 > -3) == 0);
static assert((-5 > -5) == 0);
static assert((-5 > -6) == 1);
static assert((-5 >= -3) == 0);
static assert((-5 >= -5) == 1);
static assert((-5 >= -6) == 1);
static assert((-5 <>= -3) == 1);
static assert((-5 <>= -5) == 1);
static assert((-5 <>= -6) == 1);
static assert((-5 <> -3) == 1);
static assert((-5 <> -5) == 0);
static assert((-5 <> -6) == 1);
static assert((-5 !<>= -3) == 0);
static assert((-5 !<>= -5) == 0);
static assert((-5 !<>= -6) == 0);
static assert((-5 !<> -3) == 0);
static assert((-5 !<> -5) == 1);
static assert((-5 !<> -6) == 0);
static assert((-5 !<= -3) == 0);
static assert((-5 !<= -5) == 0);
static assert((-5 !<= -6) == 1);
static assert((-5 !< -3) == 0);
static assert((-5 !< -5) == 1);
static assert((-5 !< -6) == 1);
static assert((-5 !>= -3) == 1);
static assert((-5 !>= -5) == 0);
static assert((-5 !>= -6) == 0);
static assert((-5 !> -3) == 1);
static assert((-5 !> -5) == 1);
static assert((-5 !> -6) == 0);

static assert((5u < 3u) == 0);
static assert((5u < 5u) == 0);
static assert((5u < 6u) == 1);
static assert((5u <= 3u) == 0);
static assert((5u <= 5u) == 1);
static assert((5u <= 6u) == 1);
static assert((5u > 3u) == 1);
static assert((5u > 5u) == 0);
static assert((5u > 6u) == 0);
static assert((5u >= 3u) == 1);
static assert((5u >= 5u) == 1);
static assert((5u >= 6u) == 0);
static assert((5u <>= 3u) == 1);
static assert((5u <>= 5u) == 1);
static assert((5u <>= 6u) == 1);
static assert((5u <> 3u) == 1);
static assert((5u <> 5u) == 0);
static assert((5u <> 6u) == 1);
static assert((5u !<>= 3u) == 0);
static assert((5u !<>= 5u) == 0);
static assert((5u !<>= 6u) == 0);
static assert((5u !<> 3u) == 0);
static assert((5u !<> 5u) == 1);
static assert((5u !<> 6u) == 0);
static assert((5u !<= 3u) == 1);
static assert((5u !<= 5u) == 0);
static assert((5u !<= 6u) == 0);
static assert((5u !< 3u) == 1);
static assert((5u !< 5u) == 1);
static assert((5u !< 6u) == 0);
static assert((5u !>= 3u) == 0);
static assert((5u !>= 5u) == 0);
static assert((5u !>= 6u) == 1);
static assert((5u !> 3u) == 0);
static assert((5u !> 5u) == 1);
static assert((5u !> 6u) == 1);

static assert((-5u < 3) == 0);
static assert((-5u <= 3) == 0);
static assert((-5u > 3) == 1);
static assert((-5u >= 3) == 1);
static assert((-5u <>= 3) == 1);
static assert((-5u <> 3) == 1);
static assert((-5u !<>= 3) == 0);
static assert((-5u !<> 3) == 0);
static assert((-5u !<= 3) == 1);
static assert((-5u !< 3) == 1);
static assert((-5u !>= 3) == 0);
static assert((-5u !> 3) == 0);

static assert((-5 < 3u) == 0);
static assert((-5 <= 3u) == 0);
static assert((-5 > 3u) == 1);
static assert((-5 >= 3u) == 1);
static assert((-5 <>= 3u) == 1);
static assert((-5 <> 3u) == 1);
static assert((-5 !<>= 3u) == 0);
static assert((-5 !<> 3u) == 0);
static assert((-5 !<= 3u) == 1);
static assert((-5 !< 3u) == 1);
static assert((-5 !>= 3u) == 0);
static assert((-5 !> 3u) == 0);

static assert((5.2 <    double.nan) == 0);
static assert((5.2 <=   double.nan) == 0);
static assert((5.2 >    double.nan) == 0);
static assert((5.2 >=   double.nan) == 0);
static assert((5.2 <>=  double.nan) == 0);
static assert((5.2 <>   double.nan) == 0);
static assert((5.2 !<>= double.nan) == 1);
static assert((5.2 !<>  double.nan) == 1);
static assert((5.2 !<=  double.nan) == 1);
static assert((5.2 !<   double.nan) == 1);
static assert((5.2 !>=  double.nan) == 1);
static assert((5.2 !>   double.nan) == 1);

static assert((double.nan <    6.2) == 0);
static assert((double.nan <=   6.2) == 0);
static assert((double.nan >    6.2) == 0);
static assert((double.nan >=   6.2) == 0);
static assert((double.nan <>=  6.2) == 0);
static assert((double.nan <>   6.2) == 0);
static assert((double.nan !<>= 6.2) == 1);
static assert((double.nan !<>  6.2) == 1);
static assert((double.nan !<=  6.2) == 1);
static assert((double.nan !<   6.2) == 1);
static assert((double.nan !>=  6.2) == 1);
static assert((double.nan !>   6.2) == 1);

static assert((double.nan <    double.nan) == 0);
static assert((double.nan <=   double.nan) == 0);
static assert((double.nan >    double.nan) == 0);
static assert((double.nan >=   double.nan) == 0);
static assert((double.nan <>=  double.nan) == 0);
static assert((double.nan <>   double.nan) == 0);
static assert((double.nan !<>= double.nan) == 1);
static assert((double.nan !<>  double.nan) == 1);
static assert((double.nan !<=  double.nan) == 1);
static assert((double.nan !<   double.nan) == 1);
static assert((double.nan !>=  double.nan) == 1);
static assert((double.nan !>   double.nan) == 1);

static assert((5.2 <    6.2) == 1);
static assert((5.2 <=   6.2) == 1);
static assert((5.2 >    6.2) == 0);
static assert((5.2 >=   6.2) == 0);
static assert((5.2 <>=  6.2) == 1);
static assert((5.2 <>   6.2) == 1);
static assert((5.2 !<>= 6.2) == 0);
static assert((5.2 !<>  6.2) == 0);
static assert((5.2 !<=  6.2) == 0);
static assert((5.2 !<   6.2) == 0);
static assert((5.2 !>=  6.2) == 1);
static assert((5.2 !>   6.2) == 1);

static assert((5.2 <    5.2) == 0);
static assert((5.2 <=   5.2) == 1);
static assert((5.2 >    5.2) == 0);
static assert((5.2 >=   5.2) == 1);
static assert((5.2 <>=  5.2) == 1);
static assert((5.2 <>   5.2) == 0);
static assert((5.2 !<>= 5.2) == 0);
static assert((5.2 !<>  5.2) == 1);
static assert((5.2 !<=  5.2) == 0);
static assert((5.2 !<   5.2) == 1);
static assert((5.2 !>=  5.2) == 0);
static assert((5.2 !>   5.2) == 1);

static assert((7.2 <    6.2) == 0);
static assert((7.2 <=   6.2) == 0);
static assert((7.2 >    6.2) == 1);
static assert((7.2 >=   6.2) == 1);
static assert((7.2 <>=  6.2) == 1);
static assert((7.2 <>   6.2) == 1);
static assert((7.2 !<>= 6.2) == 0);
static assert((7.2 !<>  6.2) == 0);
static assert((7.2 !<=  6.2) == 1);
static assert((7.2 !<   6.2) == 1);
static assert((7.2 !>=  6.2) == 0);
static assert((7.2 !>   6.2) == 0);

static assert((7.2i < 6.2i) == 0);


static assert((7.2i == 6.2i) == 0);
static assert((7.2i != 6.2i) == 1);
static assert((7.2 == 6.2) == 0);
static assert((7.2 != 6.2) == 1);

static assert((7.2i == 7.2i) == 1);
static assert((7.2i != 7.2i) == 0);
static assert((7.2 == 7.2) == 1);
static assert((7.2 != 7.2) == 0);

static assert((7.2 == double.nan) == 0);
static assert((7.2 != double.nan) == 1);
static assert((double.nan == double.nan) == 0);
static assert((double.nan != double.nan) == 1);
static assert((double.nan == 7.2) == 0);
static assert((double.nan != 7.2) == 1);

static assert((5 is 5) == 1);
static assert((5 is 4) == 0);
static assert((5 !is 5) == 0);
static assert((5 !is 4) == 1);

static assert((5.1 is 5.1) == 1);
static assert((5.1 is 4.1) == 0);
static assert((5.1 !is 5.1) == 0);
static assert((5.1 !is 4.1) == 1);

static assert((5.1 is 5.1i) == 0);
static assert((5.1 !is 5.1i) == 1);

static assert((5 ? 2 : 3) == 2);
static assert((0 ? 2 : 3) == 3);
static assert((5.0 ? 2 : 3) == 2);
static assert((0.0 ? 2 : 3) == 3);

static assert("abc" == "abc");

//static assert("abc"w.sizeof == 6);
//static assert("\U00010000bc"w.sizeof == 8);

static assert([1,2,3][1] == 2);
static assert([1,2,3] ~ [4] == [1,2,3,4]);
static assert([1,2,3][1..3] == [2,3]);

static assert(['a','b','c','d'] == "abcd");
static assert("efgh" == ['e','f','g','h']);
static assert("efgi" != ['e','f','g','h']);


void test1()
{
    int x;
    int y;
    int* p;

    p = &x + cast(size_t)&y;
    p = &x + 2;
    p = 4 + &y;
    p = &x - 1;

    assert((&x is &x) == 1);
    assert((&x is &y) == 0);
    assert((&x !is &x) == 0);
    assert((&x !is &y) == 1);
}

/************************************/

void test2()
{
    float f = float.infinity;
    int i = cast(int) f;
    writeln(i);
    writeln(cast(int)float.max);
    assert(i == cast(int)float.max || i == cast(int)float.max+1);
    assert(i == 0x80000000 || i == 0x7fffffff);
}

/************************************/

void test3()
{
     real n = -0.0;
     const real m = -0.0;

     creal c = -0.0 + 3i;
     creal d = n + 3i;
     creal e = m + 3i;

     // should print "11111"
     writeln(signbit(n), signbit(m),
	signbit(c.re), signbit(d.re), signbit(e.re));

     assert(signbit(n) == 1);
     assert(signbit(m) == 1);
     assert(signbit(c.re) == 1);
     assert(signbit(d.re) == 1);
     assert(signbit(e.re) == 1);
}

/************************************/

struct A4 { char [] a; }
struct B4 { long x; }
struct C4 { int a;
    static C4 opCall(int b) { C4 q; q.a=b; return q; }
}
static assert(!is(typeof( (){ A4 s; B4 q = s; })));
static assert(!is(typeof( (){ B4 x =1L; })));
static assert(is(typeof( (){ C4 g = 7; })));
static assert(is(typeof( (){ C4 g = 7; C4 h = g;})));

/************************************/

alias uint DWORD;
MY_API_FUNCTION lpStartAddress;
extern (Windows) alias DWORD function(void*) MY_API_FUNCTION;
pragma(msg, MY_API_FUNCTION.stringof);
static assert(MY_API_FUNCTION.stringof == "uint Windows function(void*)");

/************************************/

enum bug6 = cast(void*)0xFEFEFEFE;
static assert(bug6 is bug6);

/************************************/

struct S7{
   double z;
}

int bug7(int x) {  return x; }

S7 s7;
double e7 = 4;
const double d7 = 4;

static assert(!is(typeof(bug7(cast(long)e7))));
static assert(!is(typeof(bug7(cast(long)s7))));
static assert(!is(typeof(bug7(cast(long)3.256679e30))));

static assert(is(typeof(bug7(cast(long)d7))));
static assert(is(typeof(bug7(cast(long)3.256679e4))));

/************************************/

class C8 {
    int x;
}
alias C8.x F8;
static assert(is(typeof(F8) == int));
static assert(is(typeof(C8.x) == int));

/************************************/

int foo9() {
   int u = cast(int)(0x1_0000_0000L);
   while (u) {
      if (u) { 
         assert(u!=0); 
        }
      assert(u!=0);
   }
   return 2;
}

static assert(foo9()==2);

/************************************/

int main()
{
    test1();
    test2();
    test3();

    printf("Success\n");
    return 0;
}
