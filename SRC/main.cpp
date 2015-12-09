#include "mbed.h"

DigitalOut myLED1(PG_13);
DigitalOut myLED2(PG_14);
Ticker tick1;
Ticker tick2;
InterruptIn myButton(USER_BUTTON);

float delay = 0.2;

void tick_fn1()
{
  myLED1 = !myLED1;
}

void tick_fn2()
{
  myLED2 = !myLED2;
}

void push_btn()
{
  delay = (delay < 1.0)?1.0:0.2;
  tick2.attach(tick_fn2,delay);
}

int main()
{
  myLED2 = 1;
  myLED1 = 1;
  myButton.fall(push_btn);
  tick1.attach(tick_fn1,0.2);
  tick2.attach(tick_fn2,delay);

  while(1);
  return 0;
}
