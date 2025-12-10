cmake_minimum_required(VERSION 3.16)

project(cluster-ui VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick Core Gui)
find_package(vsomeip3 REQUIRED)
find_package(Threads REQUIRED)

qt_standard_project_setup()

qt_add_executable(appcluster-ui
    main.cpp
)

qt_add_qml_module(appcluster-ui
    URI ClusterUI
    VERSION 1.0
    QML_FILES main.qml Dashboard.qml
)

target_link_libraries(appcluster-ui
    PRIVATE Qt6::Quick Qt6::Core Qt6::Gui vsomeip3 ${CMAKE_THREAD_LIBS_INIT}
)

install(TARGETS appcluster-ui
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
