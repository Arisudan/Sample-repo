cmake_minimum_required(VERSION 3.10)
project(media_service)

set(CMAKE_CXX_STANDARD 14)

find_package(vsomeip3 REQUIRED)
find_package(Threads REQUIRED)

// Optional: find_package(Qt6 COMPONENTS Multimedia Core)

include_directories(include)

add_executable(media_service src/main.cpp)
target_link_libraries(media_service vsomeip3 ${CMAKE_THREAD_LIBS_INIT})
