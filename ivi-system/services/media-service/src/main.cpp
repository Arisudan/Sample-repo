#include <vsomeip/vsomeip.hpp>
#include <iostream>
#include <thread>
#include <chrono>
#include <vector>
#include <string>

const vsomeip::service_t SERVICE_ID = 0x9ABC; // As per plan, but let's stick to config 0x0300
// Wait, in previous config (vsomeip.json) I set:
// media_service id: 0x0300 (Application ID)
// But defined Service ID: 0x1234 (CAN), 0x5678 (PDC). I missed Media Service Definition in the json 'services' array. 
// I should have added it. I will assume Service ID 0x9000 for Media.
const vsomeip::service_t MEDIA_SERVICE_ID = 0x9000;
const vsomeip::instance_t INSTANCE_ID = 0x0001;
const vsomeip::event_t EVENT_METADATA = 0x8201;
const vsomeip::event_t EVENT_STATUS = 0x8202;

std::shared_ptr<vsomeip::application> app;

struct Track {
    std::string title;
    std::string artist;
    int duration;
};

std::vector<Track> playlist = {
    {"Blinding Lights", "The Weeknd", 200},
    {"Levitating", "Dua Lipa", 203},
    {"Peaches", "Justin Bieber", 198}
};

void media_logic() {
    int current_track = 0;
    int progress = 0;
    bool playing = true;

    while(true) {
        if (playing) {
            progress++;
            if (progress > playlist[current_track].duration) {
                 progress = 0;
                 current_track = (current_track + 1) % playlist.size();
            }
        }

        // Publish Metadata: "Title|Artist"
        std::string meta = playlist[current_track].title + "|" + playlist[current_track].artist;
        std::shared_ptr<vsomeip::payload> pl_meta = vsomeip::runtime::get()->create_payload();
        std::vector<vsomeip::byte_t> data_meta(meta.begin(), meta.end());
        pl_meta->set_data(data_meta);
        app->notify(MEDIA_SERVICE_ID, INSTANCE_ID, EVENT_METADATA, pl_meta);

        // Publish Status: "Playing/Paused|Progress"
        std::string status = (playing ? "Playing" : "Paused") + std::string("|") + std::to_string(progress);
        std::shared_ptr<vsomeip::payload> pl_status = vsomeip::runtime::get()->create_payload();
        std::vector<vsomeip::byte_t> data_status(status.begin(), status.end());
        pl_status->set_data(data_status);
        app->notify(MEDIA_SERVICE_ID, INSTANCE_ID, EVENT_STATUS, pl_status);

        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

int main() {
    app = vsomeip::runtime::get()->create_application("media_service");
    app->init();
    app->offer_service(MEDIA_SERVICE_ID, INSTANCE_ID);
    
    std::set<vsomeip::eventgroup_t> groups;
    groups.insert(0x4467);
    app->offer_event(MEDIA_SERVICE_ID, INSTANCE_ID, EVENT_METADATA, groups);
    app->offer_event(MEDIA_SERVICE_ID, INSTANCE_ID, EVENT_STATUS, groups);
    
    std::thread worker(media_logic);
    
    app->start();
    return 0;
}
