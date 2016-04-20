project(OpenGLExperiments)

cmake_minimum_required(VERSION 3.5)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(BINARIES_DIR "${CMAKE_SOURCE_DIR}/../bin")
set(EXTERNAL_DIR "${CMAKE_SOURCE_DIR}/../external")

option(ENABLE_CONSOLE "Enable console" OFF)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCH x64)
else()
    set(ARCH x86)
endif()

# let cmake know about prebuilt libraries
file(GLOB external_libs RELATIVE "${EXTERNAL_DIR}" "${EXTERNAL_DIR}/*")
foreach(external_lib ${external_libs})
    if(IS_DIRECTORY "${EXTERNAL_DIR}/${external_lib}")
        list(APPEND CMAKE_INCLUDE_PATH "${EXTERNAL_DIR}/${external_lib}/include")
        list(APPEND CMAKE_LIBRARY_PATH "${EXTERNAL_DIR}/${external_lib}/lib/${ARCH}/release")
    endif()
endforeach()

add_definitions(-D_UNICODE)
add_definitions(-DUNICODE)
add_compile_options(/MP)

find_package(GLFW3 REQUIRED)
add_definitions(-DGLFW_DLL)
include_directories("${GLFW3_INCLUDE_DIR}")

include_directories("${CMAKE_SOURCE_DIR}")

set(OpenGLExperiments_SOURCE main.cpp)
set(OpenGLExperiments_SHARED_LIBS ${GLFW3_LIBRARIES})

if(ENABLE_CONSOLE)
    add_executable(${PROJECT_NAME} ${OpenGLExperiments_SOURCE})
else()
    add_executable(${PROJECT_NAME} WIN32 ${OpenGLExperiments_SOURCE})
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/ENTRY:mainCRTStartup")
endif()

string(REPLACE "/release/" "/debug/" OpenGLExperiments_DEBUG_SHARED_LIBS ${OpenGLExperiments_SHARED_LIBS})
target_link_libraries(${PROJECT_NAME} optimized ${OpenGLExperiments_SHARED_LIBS} debug ${OpenGLExperiments_DEBUG_SHARED_LIBS})

target_link_libraries(${PROJECT_NAME} opengl32)

add_custom_command(
    TARGET ${PROJECT_NAME}ss
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${BINARIES_DIR}")

add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${PROJECT_NAME}>" "${BINARIES_DIR}/"
)

list(LENGTH OpenGLExperiments_SHARED_LIBS num_shared_libs)
math(EXPR num_shared_libs "${num_shared_libs} - 1")
foreach(shared_lib_index RANGE ${num_shared_libs})
    list(GET OpenGLExperiments_DEBUG_SHARED_LIBS ${shared_lib_index} debug_lib)
    string(REGEX REPLACE ".lib$" ".dll" debug_lib "${debug_lib}")
    list(GET OpenGLExperiments_SHARED_LIBS ${shared_lib_index} release_lib)
    string(REGEX REPLACE ".lib$" ".dll" release_lib "${release_lib}")
    add_custom_command(
        TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "$<$<CONFIG:Debug>:${debug_lib}>$<$<CONFIG:MinSizeRel>:${release_lib}>$<$<CONFIG:RelWithDebInfo>:${release_lib}>$<$<CONFIG:Release>:${release_lib}>" "${BINARIES_DIR}/"
    )
endforeach()
