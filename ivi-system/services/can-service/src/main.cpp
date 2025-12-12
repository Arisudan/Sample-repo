#include <vsomeip/vsomeip.hpp>
#include <iostream>
#include <thread>
#include <chrono>
#include "can_handler.h"

// Service Constants
const vsomeip::service_t SERVICE_ID = 0x1234;
const vsomeip::instance_t INSTANCE_ID = 0x0001;
const vsomeip::event_t EVENT_SPEED = 0x8001;
const vsomeip::event_t EVENT_RPM = 0x8002;
const vsomeip::event_t EVENT_GEAR = 0x8003;

std::shared_ptr<vsomeip::application> app;

void run_can_logic() {
    CanHandler can("vcan0");
    if (!can.start()) {
        std::cerr << "Failed to start CAN handler" << std::endl;
        return;
    }

    can.setCallback([&](uint32_t speed, uint32_t rpm, int gear) {
        // Serialize and publish
        // Vsomeip payload creation
        std::shared_ptr<vsomeip::payload> pl_speed = vsomeip::runtime::get()->create_payload();
        std::vector<vsomeip::byte_t> data_speed;
        data_speed.push_back((speed >> 8) & 0xFF);
        data_speed.push_back(speed & 0xFF);
        pl_speed->set_data(data_speed);
        app->notify(SERVICE_ID, INSTANCE_ID, EVENT_SPEED, pl_speed);

        std::shared_ptr<vsomeip::payload> pl_rpm = vsomeip::runtime::get()->create_payload();
        std::vector<vsomeip::byte_t> data_rpm;
        data_rpm.push_back((rpm >> 8) & 0xFF);
        data_rpm.push_back(rpm & 0xFF);
        pl_rpm->set_data(data_rpm);
        app->notify(SERVICE_ID, INSTANCE_ID, EVENT_RPM, pl_rpm);

         std::shared_ptr<vsomeip::payload> pl_gear = vsomeip::runtime::get()->create_payload();
        std::vector<vsomeip::byte_t> data_gear;
        data_gear.push_back(gear);
        pl_gear->set_data(data_gear);
        app->notify(SERVICE_ID, INSTANCE_ID, EVENT_GEAR, pl_gear);
        
        // Debug
        // std::cout << "Published CAN: " << speed << " km/h" << std::endl;
    });

    while(true) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

int main() {
    app = vsomeip::runtime::get()->create_application("can_service");
    app->init();
    app->offer_service(SERVICE_ID, INSTANCE_ID);
    
    // Register events
    std::set<vsomeip::eventgroup_t> groups;
    groups.insert(0x4465); // Random Event Group
    app->offer_event(SERVICE_ID, INSTANCE_ID, EVENT_SPEED, groups);
    app->offer_event(SERVICE_ID, INSTANCE_ID, EVENT_RPM, groups);
    app->offer_event(SERVICE_ID, INSTANCE_ID, EVENT_GEAR, groups);

    std::thread sender(run_can_logic);
    
    app->start();
    return 0;
}
