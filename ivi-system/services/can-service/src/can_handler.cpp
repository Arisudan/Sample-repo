#include "can_handler.h"
#include <iostream>
#include <cstring>
#include <unistd.h>

#ifdef __linux__
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#else
// Mocks for non-linux systems to allow code analysis
struct can_frame { uint32_t can_id; uint8_t can_dlc; uint8_t data[8]; };
#define PF_CAN 29
#define AF_CAN PF_CAN
#define SOCK_RAW 3
#define SOL_CAN_BASE 100
#define SIOCGIFINDEX 0x8933
#endif

CanHandler::CanHandler(const std::string& interface) 
    : interface_(interface), running_(false), socket_fd_(-1) {}

CanHandler::~CanHandler() {
    stop();
}

bool CanHandler::start() {
#ifdef __linux__
    struct sockaddr_can addr;
    struct ifreq ifr;

    if ((socket_fd_ = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
        perror("Socket");
        return false;
    }

    strcpy(ifr.ifr_name, interface_.c_str());
    if (ioctl(socket_fd_, SIOCGIFINDEX, &ifr) < 0) {
        perror("IOCTL");
        return false;
    }

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(socket_fd_, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("Bind");
        return false;
    }
#endif
    running_ = true;
    worker_ = std::thread(&CanHandler::loop, this);
    return true;
}

void CanHandler::stop() {
    running_ = false;
    if (worker_.joinable()) {
        worker_.join();
    }
    if (socket_fd_ >= 0) {
        close(socket_fd_);
        socket_fd_ = -1;
    }
}

void CanHandler::setCallback(std::function<void(uint32_t speed, uint32_t rpm, int gear)> cb) {
    callback_ = cb;
}

void CanHandler::loop() {
    struct can_frame frame;
    while (running_) {
#ifdef __linux__
        int nbytes = read(socket_fd_, &frame, sizeof(struct can_frame));
        if (nbytes < 0) {
            perror("Read");
            // Simple retry logic or break
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            continue;
        }

        if (callback_) {
            // Mock decoding strategy:
            // ID 0x100: Speed (bytes 0-1), RPM (bytes 2-3), Gear (byte 4)
            if (frame.can_id == 0x100) {
                uint32_t speed = (frame.data[0] << 8) | frame.data[1];
                uint32_t rpm = (frame.data[2] << 8) | frame.data[3];
                int gear = frame.data[4];
                callback_(speed, rpm, gear);
            }
        }
#else
        // Simulation for non-linux env
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        static uint32_t s = 0;
        if(callback_) callback_(s++ % 200, (s * 50) % 8000, (s / 20) % 6);
#endif
    }
}
