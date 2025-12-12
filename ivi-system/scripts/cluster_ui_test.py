
import sys
import socket
import json
import time

TARGET_IP = "127.0.0.1"
TARGET_PORT = 12345

def send_update(sock, data):
    msg = json.dumps(data).encode('utf-8')
    sock.sendto(msg, (TARGET_IP, TARGET_PORT))
    # print(f"Sent: {data}")

def main():
    print("Starting ASTER Cluster Simulation...")
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    # Init
    send_update(sock, {"speed": 0, "rpm": 0, "gear": "P", "nav_active": False})
    time.sleep(1)

    # 1. Start Engine
    print("-> Engine Start")
    for r in range(0, 1000, 50):
        send_update(sock, {"rpm": r})
        time.sleep(0.05)
    
    # 2. Shift to D
    time.sleep(0.5)
    print("-> Shift D")
    send_update(sock, {"gear": "D"})
    time.sleep(0.5)
    
    # 3. Accelerate
    print("-> Accelerating 0-120")
    for s in range(0, 120):
        rpm = 1500 + s * 30
        if s > 60: rpm = 3000 + (s-60)*40 # shift logic sim
        send_update(sock, {"speed": s, "rpm": rpm})
        time.sleep(0.05) # 20hz updates
        
    # 4. Turn Signal
    print("-> Left Turn Signal")
    send_update(sock, {"left": True})
    time.sleep(2)
    send_update(sock, {"left": False})
    
    # 5. Nav Activation
    print("-> Navigation Active")
    send_update(sock, {"nav_active": True, "destination": "HOME"})
    time.sleep(3)
    
    # 6. Stop
    print("-> Braking")
    for s in range(120, 0, -2):
        send_update(sock, {"speed": s, "rpm": 1000 + s*10})
        time.sleep(0.05)
        
    send_update(sock, {"gear": "P", "nav_active": False, "speed":0, "rpm":0})
    print("Simulation Complete.")

if __name__ == "__main__":
    main()
