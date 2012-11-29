#include <Servo.h> 

int door_pin = 2;
int sensor_pin[] = { 3, 4, 5, 6, 7, 8 };
#define sensors (sizeof(sensor_pin)/sizeof(servo_pin[0]))
int servo_pin[] = { 9, 10 };
#define servos (sizeof(servo_pin)/sizeof(servo_pin[0]))
int servo_pos[][4] = { { 80, 10, 25, 45 }, { 5, 80, 65, 45 } };

Servo servo[2];
 
void setup() 
{ 
  Serial.begin(9600);
  int i;
  pinMode(door_pin, OUTPUT);
  digitalWrite(door_pin, LOW);
  for (i = 0; i < sensors; i++)
    pinMode(sensor_pin[i], INPUT);
  for (i = 0; i < servos; i++) {
    servo[i].attach(servo_pin[i]);
    servo[i].write(servo_pos[i][2]);
  }
} 

void calibrate()
{
  int i;
  for (i = 0; i < 80; i++) {
    servo[0].write(i);
    Serial.println(i);
    delay(250);
  }
  delay(1000);
}

void sensor_info()
{
byte i;
i = 0;

//if (digitalRead(sensor_pin[1]) == true) i = i + 1;
//if (digitalRead(sensor_pin[2]) == true) i = i + 2;
//if (digitalRead(sensor_pin[3]) == true) i = i + 4;
//if (digitalRead(sensor_pin[4]) == true) i = i + 8;
//if (digitalRead(sensor_pin[5]) == true) i = i + 16;
//if (digitalRead(sensor_pin[6]) == true) i = i + 32;

if (digitalRead(3) == true) i = i + 1;
if (digitalRead(4) == true) i = i + 2;
if (digitalRead(5) == true) i = i + 4;
if (digitalRead(6) == true) i = i + 8;
if (digitalRead(7) == true) i = i + 16;
if (digitalRead(8) == true) i = i + 32;

    Serial.print(i, BIN);
}

void loop_ro() 
{
  sensor_info();
  digitalWrite(door_pin, LOW);
  delay(1000);
  sensor_info();
  digitalWrite(door_pin, HIGH);
  delay(1000);
}

void loop_rw()
{
  if (Serial.available()) {
    unsigned char cmd = Serial.read();
    int sid = 0;
    switch (cmd) {
      case 'd': digitalWrite(door_pin, LOW); break;
      case 'D': digitalWrite(door_pin, HIGH); break;
      case 'S': sid = 1; // fall through
      case 's': /* sid = 0; */ {
	while (!Serial.available()) /* spin */;
        unsigned char pos = Serial.read();
	if (pos >= '0' && pos <= '3')
		servo[sid].write(servo_pos[sid][pos - '0']);
      }
    }
  }
  sensor_info();
  delay(100);
}

void loop()
{
  loop_rw(); return; // Interactive
  loop_ro(); return; // Non-interactive, door cycling
  calibrate(); return; // Calibrate
}
