import network
import socket
import time
import binascii

WIFI_SSID = "123"
WIFI_PASSWORD = "123!"  # your real WiFi credentials

TARGET_MAC = "123"  # your PC MAC
SECRET_TOKEN = "123!"   # shared secret with Orange Pi
SECUREON_PASSWORD = "11:11:11:11:11:11"   # WoL SecureOn password (6 bytes, hex)

# will be set after WiFi connects
BROADCAST_IP = None

def get_broadcast_ip(wlan):
    ip, netmask, _, _ = wlan.ifconfig()
    ip_parts   = [int(x) for x in ip.split(".")]
    mask_parts = [int(x) for x in netmask.split(".")]
    bcast_parts = [(ip_parts[i] | (255 - mask_parts[i])) for i in range(4)]
    return ".".join(str(x) for x in bcast_parts)


def wake_on_lan(mac, bcast_ip, secureon_password=None):
    # Normalize MAC: remove : or -
    mac = mac.replace(":", "").replace("-", "")
    mac_bytes = binascii.unhexlify(mac)

    magic_packet = b"\xff" * 6 + mac_bytes * 16  # base WoL packet

    # If a SecureOn password is provided, append its 6 bytes
    if secureon_password:
        pwd = secureon_password.replace(":", "").replace("-", "")
        if len(pwd) != 12:
            print("Invalid SecureOn password length (need 6 bytes / 12 hex chars)")
        else:
            pwd_bytes = binascii.unhexlify(pwd)
            magic_packet += pwd_bytes

    print("Magic packet length:", len(magic_packet))  # 102 without pwd, 108 with pwd

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    try:
        sent = sock.sendto(magic_packet, (bcast_ip, 9))
        print("Bytes actually sent:", sent)
    except Exception as e:
        print("Send failed:", e)
    finally:
        sock.close()

    print("WOL sent to", mac, "via", bcast_ip)


def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(WIFI_SSID, WIFI_PASSWORD)

    print("Connecting to WiFi...")
    while not wlan.isconnected():
        time.sleep(1)
        print("Waiting...")

    print("Connected:", wlan.ifconfig())
    return wlan

def handle_client(client):
    global BROADCAST_IP

    req = client.recv(1024)
    request_line = req.split(b"\r\n", 1)[0]
    print("Request:", request_line)

    if b"GET /wake" in request_line:
        if f"token={SECRET_TOKEN}".encode() in request_line:
            try:
                wake_on_lan(TARGET_MAC, BROADCAST_IP)
                body = "OK: WOL sent\n"
                status = "200 OK"
            except Exception as e:
                body = "ERROR: %s\n" % repr(e)
                status = "500 Internal Server Error"
        else:
            body = "Forbidden\n"
            status = "403 Forbidden"
    else:
        body = "Pico W WOL service\n"
        status = "200 OK"

    response = (
        "HTTP/1.1 " + status + "\r\n"
        "Content-Type: text/plain\r\n"
        "Content-Length: " + str(len(body)) + "\r\n"
        "\r\n" +
        body
    )
    client.send(response.encode())   # send bytes
    client.close()

def start_server():
    addr = socket.getaddrinfo("0.0.0.0", 80)[0][-1]
    s = socket.socket()
    s.bind(addr)
    s.listen(1)
    print("HTTP server on port 80")

    while True:
        client, addr = s.accept()
        print("Client:", addr)
        handle_client(client)

# ---- main ----
wlan = connect_wifi()
BROADCAST_IP = get_broadcast_ip(wlan)
print("Broadcast IP:", BROADCAST_IP)
print("Pico IP:", wlan.ifconfig()[0])

start_server()
