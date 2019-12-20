cmake_minimum_required(VERSION 3.10)

project(pres.io LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick Xml Gui Qml REQUIRED)

set (FILES
  src/main.cpp
  src/Util.cpp
  src/Launcher.cpp
  src/TextModel.cpp
  )

add_executable(${PROJECT_NAME}
  ${FILES}
  "qml.qrc"
)
  
target_link_libraries(${PROJECT_NAME}
  Qt5::Core Qt5::Quick Qt5::Xml Qt5::Gui Qt5::Qml
)
