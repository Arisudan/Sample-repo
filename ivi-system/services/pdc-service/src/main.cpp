#include <vsomeip/vsomeip.hpp>
#include <iostream>
#include <thread>
#include <chrono>
#include <fstream>
#include <cmath>

const vsomeip::service_t SERVICE_ID = 0x5678;
const vsomeip::instance_t INSTANCE_ID = 0x0001;
const vsomeip::event_t EVENT_DISTANCE = 0x8101;

std::shared_ptr<vsomeip::application> app;

// Mock function to read distance from sensor
// In production, this would interface with valid GPIO or a kernel driver
double read_distance_sensor() {
   // Simulating a car backing up to an obstacle
   static double dist = 200.0; // cm
   static double step = -1.0;
   
   dist += step;
   if (dist < 10.0) step = 1.0;
   if (dist > 200.0) step = -1.0;
   
   return dist;
}

void pdc_logic() {
    while(true) {
        double dist = read_distance_sensor();
        
        // Publish via vsomeip
        std::shared_ptr<vsomeip::payload> pl = vsomeip::runtime::get()->create_payload();
        std::vector<vsomeip::byte_t> data;
        // Simple 1 byte for cm if < 255
        uint8_t d_byte = (dist > 255) ? 255 : (uint8_t)dist;
        data.push_back(d_byte);
        pl->set_data(data);
        app->notify(SERVICE_ID, INSTANCE_ID, EVENT_DISTANCE, pl);

        // Audible Beep Logic (Simulated print)
        if (dist < 30) {
            std::cout << "\a"; // System bell
            std::cout << "CRITICAL STOP! " << dist << "cm" << std::endl;
        } else if (dist < 100) {
            std::cout << "Beep... " << dist << "cm" << std::endl;
        }
        
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }
}

int main() {
    app = vsomeip::runtime::get()->create_application("pdc_service");
    app->init();
    app->offer_service(SERVICE_ID, INSTANCE_ID);
    
    std::set<vsomeip::eventgroup_t> groups;
    groups.insert(0x4466);
    app->offer_event(SERVICE_ID, INSTANCE_ID, EVENT_DISTANCE, groups);
    
    std::thread worker(pdc_logic);
    
    app->start();
    return 0;
}
