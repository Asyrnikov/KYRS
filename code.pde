#include <Wire.h>
#include <hd44780.h>
#include <hd44780ioClass/hd44780_I2Cexp.h>

hd44780_I2Cexp LCD;

#define QR Serial1

String inputString = "";

void scrollMessage(String inputString, int delayTime)
{
  for(int position = 0; position <= (inputString.length() - 16); position++) {
    if (QR.available()) {
      return;
    }
    LCD.clear();
    LCD.setCursor(0, 0);
    LCD.print(inputString.substring(position, position + 16));
    delay((position == 0 || position == inputString.length() - 16 ? 3 : 1) * delayTime);
  }
}

void setup()
{
  LCD.begin(16, 2);
  LCD.setCursor(0, 0);
  Serial.begin(115200);
  QR.begin(9600, SERIAL_8N1, 26, 27); //Определяем порт QR
}

void loop()
{
  if (QR.available()) // Проверяем, есть ли входящие данные в последовательном буфере
  {
    inputString = "";
    LCD.clear();
    LCD.print("Scanning...");
    delay(1000);
    while (QR.available()) // Читаем байт за байтом из буфера, пока буфер не станет пустым
    {
      char input = QR.read();// Читаем 1 байт данных и сохраняем его в переменную
      inputString += input;
    }
    inputString = inputString.substring(0, inputString.length() - 1);
    if (inputString.length() <= 16) {
      LCD.clear();
      LCD.setCursor(0, 0);
      LCD.print(inputString);
    }
  }
  if (inputString.length() > 16) {
    scrollMessage(inputString, 400);
  }
}
