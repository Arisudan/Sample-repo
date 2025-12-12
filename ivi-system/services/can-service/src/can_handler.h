#ifndef CAN_HANDLER_H
#define CAN_HANDLER_H

#include <string>
#include <thread>
#include <atomic>
#include <functional>

class CanHandler {
public:
    CanHandler(const std::string& interface);
    ~CanHandler();

    bool start();
    void stop();
    void setCallback(std::function<void(uint32_t speed, uint32_t rpm, int gear)> cb);

private:
    void loop();
    
    std::string interface_;
    std::thread worker_;
    std::atomic<bool> running_;
    int socket_fd_;
    std::function<void(uint32_t, uint32_t, int)> callback_;
};

#endif // CAN_HANDLER_H
