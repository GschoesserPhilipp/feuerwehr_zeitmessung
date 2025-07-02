cmake_minimum_required(VERSION 3.16)

project(feuerwehr_zeitmessung VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core Bluetooth Sql)

qt_standard_project_setup(REQUIRES 6.8)

# /src
file(GLOB SOURCES RELATIVE ${CMAKE_SOURCE_DIR} "src/*.cpp" "src/*.h")

# /qml
file(GLOB QML_FILES RELATIVE ${CMAKE_SOURCE_DIR} "qml/*.qml")

# resources
file(GLOB IMAGE_RESOURCES RELATIVE ${CMAKE_SOURCE_DIR} "images/*")
file(GLOB SOUND_RESOURCES RELATIVE ${CMAKE_SOURCE_DIR} "sound/*")

foreach(qml_file IN LISTS QML_FILES)
    set_property(SOURCE "${qml_file}" PROPERTY QT_RESOURCE_ALIAS "${qml_file}")
endforeach()

qt_add_executable(feuerwehr_zeitmessung
    src/main.cpp
    ${SOURCES}
)

qt_add_qml_module(feuerwehr_zeitmessung
    URI feuerwehr_zeitmessung
    VERSION 1.0


    SOURCES ${SOURCES}

    QML_FILES ${QML_FILES}

    RESOURCES
        ${IMAGE_RESOURCES}
        ${SOUND_RESOURCES}
)

set_property(TARGET feuerwehr_zeitmessung PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_SOURCE_DIR}/android)

target_link_libraries(feuerwehr_zeitmessung
    PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::Bluetooth
    Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS feuerwehr_zeitmessung
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
