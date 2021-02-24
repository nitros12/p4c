# CMakefile for the GPU P4-16 backend.

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/version.h.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/version.h" @ONLY)

set(P4C_GPU_SOURCES
        p4c-gpu.cpp
        gpuModel.cpp
        midend.cpp
        ../../backends/ebpf/ebpfProgram.cpp
        ../../backends/ebpf/ebpfTable.cpp
        ../../backends/ebpf/ebpfParser.cpp
        ../../backends/ebpf/ebpfControl.cpp
        ../../backends/ebpf/ebpfOptions.cpp
        ../../backends/ebpf/target.cpp
        ../../backends/ebpf/codeGen.cpp
        ../../backends/ebpf/ebpfType.cpp
        ../../backends/ebpf/ebpfModel.cpp
        ../../backends/ebpf/midend.cpp
        ../../backends/ebpf/lower.cpp)

set(P4C_GPU_HEADERS
        gpuModel.h
        midend.h)

set (P4C_GPU_DIST_HEADERS p4include/gpu_model.p4)

add_cpplint_files(${CMAKE_CURRENT_SOURCE_DIR} "${P4C_GPU_SOURCES}")

build_unified(P4C_GPU_SOURCES ALL)
add_executable(p4c-gpu ${P4C_GPU_SOURCES})
target_link_libraries (p4c-gpu ${P4C_LIBRARIES} ${P4C_LIB_DEPS})
add_dependencies(p4c-gpu genIR frontend)

install (TARGETS p4c-gpu
        RUNTIME DESTINATION ${P4C_RUNTIME_OUTPUT_DIRECTORY})
install (DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/p4include
        DESTINATION ${P4C_ARTIFACTS_OUTPUT_DIRECTORY})


add_custom_target(linkp4cgpu
        COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_CURRENT_BINARY_DIR}/p4c-gpu ${P4C_BINARY_DIR}/p4c-gpu
        COMMAND ${CMAKE_COMMAND} -E make_directory ${P4C_BINARY_DIR}/p4include &&
        ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/${P4C_GPU_DIST_HEADERS} ${P4C_BINARY_DIR}/p4include
        COMMAND ${CMAKE_COMMAND} -E create_symlink ${P4C_BINARY_DIR}/p4include ${CMAKE_CURRENT_BINARY_DIR}/p4include
        )

add_dependencies(p4c_driver linkp4cgpu)
