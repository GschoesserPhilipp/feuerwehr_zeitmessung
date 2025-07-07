cmake_minimum_required(VERSION 3.16)

project(feuerwehr_zeitmessung VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 COMPONENTS Quick Core Bluetooth Multimedia REQUIRED)

# Executable
qt_add_executable(feuerwehr_zeitmessung_app
    src/main.cpp
    src/BleHandler.cpp
    src/BleHandler.h
)

qt_add_qml_module(feuerwehr_zeitmessung_app
    URI feuerwehr_zeitmessung
    VERSION 1.0

    # Explicitly declare Main.qml as the main file
    NO_PLUGIN
    NO_GENERATE_PLUGIN_SOURCE

    QML_FILES
        qml/Main.qml  # This should be your root QML component
        qml/Counter.qml
        qml/DeviceList.qml
        qml/ErrorList.qml
        qml/History.qml

    RESOURCES
        images/add_group.svg
        images/connect.svg
        images/error_list.svg
        images/fire.png
        images/list.svg
        images/settings.svg
        images/timer.svg
        sound/angriffsbefehl.wav
        sound/angriffsbefehl.mp3
)

target_link_libraries(feuerwehr_zeitmessung_app
    PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::Bluetooth
    Qt6::Multimedia
)

# Android-specific setup
set_property(TARGET feuerwehr_zeitmessung_app PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_SOURCE_DIR}/android)

install(TARGETS feuerwehr_zeitmessung_app
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
