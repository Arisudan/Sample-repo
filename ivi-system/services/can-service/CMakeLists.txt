cmake_minimum_required(VERSION 3.10)
project(can_service)

set(CMAKE_CXX_STANDARD 14)

find_package(vsomeip3 REQUIRED)
find_package(Threads REQUIRED)

include_directories(include)

add_executable(can_service src/main.cpp src/can_handler.cpp)
target_link_libraries(can_service vsomeip3 ${CMAKE_THREAD_LIBS_INIT})
