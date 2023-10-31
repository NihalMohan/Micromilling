#include <Arduino.h>

const int PIEZO_PIN = 1;      // Piezo transducer GPIO pin
const int numSamples = 1024;    // Buffer for samples
int piezoData[numSamples];     // Array to store piezo ADC values
int sampleCount = 0;           // Counter for the number of samples collected

void setup()
{
  Serial.begin(2000000);       // baud rate for transmission

  // Set the resolution of the ADC to 12 bits (0-4095)
  analogReadResolution(12);

}

void loop()
{
  
  if (sampleCount < numSamples)
  {
    int piezoADC = analogRead(PIEZO_PIN);  
    piezoData[sampleCount] = piezoADC;  // Store the ADC value in piezoData array
    sampleCount++;
  }

  if (sampleCount == numSamples)  // send binary data stream for every 1024 data samples
  {
    // Send the data over the serial port as binary data
    Serial.write((uint8_t*)piezoData, numSamples * sizeof(int));
    sampleCount = 0;
  }
}
