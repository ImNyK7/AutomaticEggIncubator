#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <DHT.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

#define FIREBASE_HOST "iotbackend-696ca-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "WE7YUKBpSMo07nUT8ZWYS9Tp5Gegx7mrI873WZw2"
#define WIFI_SSID "test"
#define WIFI_PASSWORD "sepedapancal"

#define DHTPIN D5  // Pin where the DHT11 sensor is connected
#define DHTTYPE DHT11  // DHT sensor type
#define FAN_PIN D6  // Pin for relay 1
#define LIGHT_PIN D7  // Pin for relay 2

LiquidCrystal_I2C lcd(0x27, 16, 2);

DHT dht(DHTPIN, DHTTYPE);
FirebaseData firebaseData;

bool fanState = false;   // Initial state for the fan relay
bool lightState = false; // Initial state for the light relay

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

void setup() {
  Serial.begin(115200);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected to WiFi, IP address: ");
  Serial.println(WiFi.localIP());

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  dht.begin();

  lcd.init();
  lcd.backlight();
  lcd.setBacklight(HIGH);

  pinMode(FAN_PIN, OUTPUT);
  pinMode(LIGHT_PIN, OUTPUT);

  // Initialize relay states based on Firebase values on startup
  Firebase.getBool(firebaseData, "/FanStates/switch");
  if (firebaseData.dataType() == "boolean") {
    fanState = firebaseData.boolData();
    digitalWrite(FAN_PIN, fanState ? HIGH : LOW);
  }

  Firebase.getBool(firebaseData, "/LightStates/switch");
  if (firebaseData.dataType() == "boolean") {
    lightState = firebaseData.boolData();
    digitalWrite(LIGHT_PIN, lightState ? HIGH : LOW);
  }

  // Initialize the time client
  timeClient.begin();
  timeClient.setTimeOffset(25200); // Set the time offset in seconds (if necessary)

  // Fetch and update the time from the NTP server
  while (!timeClient.update()) {
    timeClient.forceUpdate();
  }
}

void recordTimestamp(const String& path, float temperature, float humidity) {
  timeClient.update();
  String timestamp = timeClient.getFormattedTime();

  Firebase.setString(firebaseData, path + "/Timestamp/" + timestamp + "/Temperature", String(temperature));
  Firebase.setString(firebaseData, path + "/Timestamp/" + timestamp + "/Humidity", String(humidity));
  Firebase.setString(firebaseData, path + "/Timestamp/" + timestamp + "/Time", timestamp);
}

void loop() {
  // Read sensor values and update Firebase
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
      lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("dht fail");
    return;
  }

  String path = "/Data";
  Firebase.setFloat(firebaseData, path + "/Humidity:", humidity);
  Firebase.setFloat(firebaseData, path + "/Temperature:", temperature);
  recordTimestamp(path, temperature, humidity);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("T:");
  lcd.setCursor(3, 0);
  lcd.print(temperature);
  lcd.setCursor(7, 0);
  lcd.print((char)223);
  lcd.print(" ");
  lcd.setCursor(8, 0);
  lcd.print("C");
  lcd.setCursor(10, 0);
  lcd.print("H:");
  lcd.setCursor(13, 0);
  lcd.print(humidity);
  lcd.setCursor(15, 0);
  lcd.print("%");

  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.print("°C ");
  Serial.println();
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print("%");
  Serial.println();

  lcd.setCursor(0, 1);
  lcd.print("FAN:");
  lcd.setCursor(4, 1);
  if (temperature > 40) {
    digitalWrite(FAN_PIN, LOW);
    lcd.print("ON");
  }
  else {
    digitalWrite(FAN_PIN, HIGH);
    lcd.print("OFF");
  }
  recordTimestamp("/Data", temperature, humidity);

  lcd.setCursor(8, 1);
  lcd.print("LAMP:");
  lcd.setCursor(13, 1);
  if (temperature > 45) {
    if (!lightState) {
      digitalWrite(LIGHT_PIN, HIGH);
      lightState = true;
      //delay(20000); // Delay for 20 seconds (lamp off)
    }
    lcd.print("OFF");
  }
  else {
    digitalWrite(LIGHT_PIN, LOW);
    lightState = false;
    lcd.print("ON");
  }

  delay(5000); // Wait for 3 seconds before sending the next reading
}
