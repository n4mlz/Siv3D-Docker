cmake_minimum_required(VERSION 3.20)

project(Siv3DTemplate CXX)

find_package(Siv3D REQUIRED)

add_executable(Siv3DTemplate
    src/Main.cpp
)

target_link_libraries(Siv3DTemplate PRIVATE Siv3D::Siv3D)
target_compile_features(Siv3DTemplate PRIVATE cxx_std_20)
