mainprog myprogram;

int toto;
int[3] intArray;
float aFloat;
float[6] floatArray;

function aFunction(float : tata) : float
  BEGIN
    print(tata);
  END
/* -------------------*
*   this is a comment *
*   on a few lines    *
*  -------------------*/
function name (int : abc) : int
  int anInt;
  float hello;
  BEGIN
    hello = 2.6;
    toto = 3;
    anInt = 4;
    print(hello);
    aFunction(hello);
  END

function withIf : float
  float f;
  int i;
  BEGIN
    i = 4;
    if i == 4 :
      f = 3.5;
    elif i == 3 :
      f = 6.7;
    else :
      f = 10.0;
    return f;
  END
//another comment
function whileFor : int
  int b;
  BEGIN
    while toto :
      aFloat = aFloat + 0.1;
    for toto in intArray :
      b = b - 1;
      aFloat = b*3;
  END
EOF
