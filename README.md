Using the Wake-on-LAN Server

<img width="496" height="403" alt="image" src="https://github.com/user-attachments/assets/5a3aa6b5-03cf-4a3b-b291-0bf86189a359" />


Once the Pico W has been flashed with MicroPython from your ubuntu machine cp "/path/to/RPI_PICO_W-20250911-v1.26.1.uf2" /media/youruser/RPI-RP2 and main.py is on the device, it becomes a tiny HTTP server on your Wi-Fi network. 

Here’s how it works:

📡 1. The Pico connects to your Wi-Fi

When powered, the Pico W:

activates its Wi-Fi interface

connects to your configured SSID

prints its IP address and broadcast address to the USB serial console

You’ll see something like:

Pico IP: 192.168.1.77
Broadcast IP: 192.168.1.255
HTTP server on port 80


This tells you where the server lives on your LAN.

🌍 2. You visit the Pico’s URL from any device

Enter the Pico’s IP in your browser:

http://PICO_IP/


Example:

http://192.168.1.77/


This is a simple landing page that confirms the Pico is alive:

Pico W WOL service

🚀 3. Trigger the Wake-on-LAN packet

To wake your desktop PC, call:

http://PICO_IP/wake?token=YOUR_SECRET_TOKEN


Example:

http://192.168.1.77/wake?token=mysecuretoken


What happens next:

Pico validates the token

Pico builds a correct WOL Magic Packet:

6 × 0xFF

16 × target MAC address

If a SecureOn password is configured in both:

Ubuntu NetworkManager

Pico’s main.py
…then 6 more bytes are appended

Pico broadcasts the packet to your LAN on UDP port 9

Your AORUS motherboard NIC receives it and powers on the PC

🔧 Diagram (conceptual architecture)

Here is the conceptual flow (as shown in your image):

+-------------------------------------------------------------+
|                         ISP / LAN                           |
|                                                             |
|   ┌──────────┐            Magic Packet + Password            |
|   │ Aorus PC │ <-----------------------------------------┐  |
|   └──────────┘                                             | |
|                       Pico MicroPython WOL Server          | |
|                            (HTTP, UDP)                     | |
|                                                             | |
|                           ▲                                 | |
|                           │                                 | |
+---------------------------│---------------------------------+ |
                            │                                   |
                            │ HTTP request                       |
                            ▼                                   |
                   Actor (Phone / Browser)                      |
                http://raspberrypicow/wake?password             |


(For GitHub users: upload /mnt/data/912de706-1f34-4288-8dca-08ed4eb2b3da.png to your repo and embed it with ![WOL Diagram](diagram.png).)

🧠 Summary

The Pico W is a small web server that listens for /wake requests

Your phone or browser sends a URL containing a secret token

The Pico sends the exact WOL packet your AORUS motherboard expects

BIOS must allow LAN power (IO/IOP Onboard LAN Controller enabled)

Ubuntu must have WoL enabled in NetworkManager

PC powers on remotely — even from complete shutdown
