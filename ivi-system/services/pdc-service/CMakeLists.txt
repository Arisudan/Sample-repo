cmake_minimum_required(VERSION 3.10)
project(pdc_service)

set(CMAKE_CXX_STANDARD 14)

find_package(vsomeip3 REQUIRED)
find_package(Threads REQUIRED)

include_directories(include)

add_executable(pdc_service src/main.cpp)
target_link_libraries(pdc_service vsomeip3 ${CMAKE_THREAD_LIBS_INIT})
