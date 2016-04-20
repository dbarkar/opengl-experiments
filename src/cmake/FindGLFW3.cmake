find_path(GLFW3_INCLUDE_DIR
    NAMES glfw3.h
    HINTS ENV GLFW3_DIR
    PATH_SUFFIXES include/GLFW include GLFW
)

find_library(GLFW3_LIBRARIES
    NAMES glfw3 libglfw3 glfw
    HINTS ENV GLFW3_DIR
    PATH_SUFFIXES lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GLFW3 DEFAULT_MSG GLFW3_LIBRARIES GLFW3_INCLUDE_DIR)
