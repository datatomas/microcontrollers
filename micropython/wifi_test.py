import network
import socket
import time
import binascii
WIFI_SSID = "123"
WIFI_PASSWORD = "123!"  # your real WiFi credentials

TARGET_MAC = "123"  # your PC MAC
SECRET_TOKEN = "123!"   # shared secret with Orange Pi


def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(WIFI_SSID, WIFI_PASSWORD)
    print("Connecting to WiFi...")
    
    max_wait = 30
    while max_wait > 0:
        if wlan.isconnected():
            break
        time.sleep(1)
        print("Waiting...", wlan.status())  # Add status code
        max_wait -= 1
    
    if not wlan.isconnected():
        print("Failed to connect. Status:", wlan.status())
        raise Exception("WiFi Connection Failed")
    
    print("Connected:", wlan.ifconfig())
    return wlan
wlan = connect_wifi()
print("Pico IP:", wlan.ifconfig()[0])
