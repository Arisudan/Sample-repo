
import sys
import socket
import json
import time

TARGET_IP = "127.0.0.1"
TARGET_PORT = 12345

def send_update(data):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    msg = json.dumps(data).encode('utf-8')
    sock.sendto(msg, (TARGET_IP, TARGET_PORT))
    print(f"Sent: {msg}")

def test_sequence():
    print("Starting Cluster UI Test Sequence...")
    
    # 1. Idle
    send_update({"speed": 0, "rpm": 800, "gear": "P"})
    time.sleep(1)
    
    # 2. Start Engine
    send_update({"rpm": 1200, "gear": "N"})
    time.sleep(1)
    
    # 3. Drive OFF
    send_update({"gear": "D"})
    time.sleep(0.5)
    
    # Acceleration Ramp
    for s in range(0, 120, 5):
        rpm = 1500 + s * 30
        send_update({"speed": s, "rpm": rpm})
        time.sleep(0.1) # 10Hz updates
    
    # 4. Indicators
    print("Testing Indicators...")
    # Toggles are internal usually, but we can verify state reflection if we loopback
    # Here we just keep driving
    
    # 5. Nav Activation
    print("Activating Navigation...")
    send_update({"nav_active": True})
    time.sleep(2)
    
    # 6. Stop
    send_update({"speed": 0, "rpm": 800, "nav_active": False, "gear": "P"})
    print("Test Sequence Complete.")

if __name__ == "__main__":
    try:
        test_sequence()
    except KeyboardInterrupt:
        pass
