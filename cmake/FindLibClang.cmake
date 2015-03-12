if (NOT DEFINED CLANG_ROOT)
  set(CLANG_ROOT $ENV{CLANG_ROOT})
endif ()

set(llvm_config_names
  llvm-config
  llvm-config38
  llvm-config-3.8
  llvm-config-mp-3.8
  llvm-config37
  llvm-config-3.7
  llvm-config-mp-3.7
  llvm-config36
  llvm-config-3.6
  llvm-config-mp-3.6
  llvm-config35
  llvm-config-3.5
  llvm-config-mp-3.5
  llvm-config34
  llvm-config-3.4
  llvm-config-mp-3.4
  llvm-config33
  llvm-config-3.3
  llvm-config-mp-3.3
  llvm-config32
  llvm-config-3.2
  llvm-config-mp-3.2
  llvm-config31
  llvm-config-3.1
  llvm-config-mp-3.1)
find_program(LLVM_CONFIG_EXECUTABLE NAMES ${llvm_config_names})

if (LLVM_CONFIG_EXECUTABLE)
  message(STATUS "LLVM llvm-config found at: ${LLVM_CONFIG_EXECUTABLE}")
else ()
  message(FATAL_ERROR "Could NOT find LLVM executable.")
endif ()

if (NOT EXISTS ${CLANG_INCLUDE})
  find_path(CLANG_INCLUDE_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT clang-c/Index.h HINTS ${CLANG_ROOT}/include NO_DEFAULT_PATH)
  if (NOT EXISTS ${CLANG_INCLUDE_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
    execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --includedir OUTPUT_VARIABLE CLANG_INCLUDE OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT EXISTS ${CLANG_INCLUDE})
      find_path(CLANG_INCLUDE clang-c/Index.h)
      if (NOT EXISTS ${CLANG_INCLUDE})
        message(FATAL_ERROR "Could NOT find clang include path. You can fix this by setting CLANG_INCLUDE in your shell or as a cmake variable.")
      endif ()
    endif ()
  else ()
    set(CLANG_INCLUDE ${CLANG_INCLUDE_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
  endif ()
endif ()

if (NOT EXISTS ${CLANG_LIBDIR})
  execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --libdir OUTPUT_VARIABLE CLANG_LIBDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
  if (NOT EXISTS ${CLANG_LIBDIR})
    message(FATAL_ERROR "Could NOT find clang libdir. You can fix this by setting CLANG_LIBDIR in your shell or as a cmake variable.")
  endif ()
endif ()

if (NOT EXISTS ${CLANG_LIBS})
  find_library(CLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT NAMES clang libclang ${CLANG_ROOT}/lib NO_DEFAULT_PATH)
  if (NOT EXISTS ${CLANG_CLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
    if (NOT EXISTS ${CLANG_LIBDIR})
      find_library(CLANG_LIBS NAMES clang libclang)
      if (NOT EXISTS ${CLANG_LIBS})
        message(FATAL_ERROR "Could NOT find clang libraries. You can fix this by setting CLANG_LIBS in your shell or as a cmake variable.")
      endif ()
    else ()
      set (CLANG_LIBS "-L${CLANG_LIBDIR}" "-lclang" "-Wl,-rpath,${CLANG_LIBDIR}")
    endif ()
  else ()
    set(CLANG_LIBS "${CLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT}")
  endif ()
endif ()

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --version OUTPUT_VARIABLE CLANG_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
message("-- Using Clang ${CLANG_VERSION} from ${CLANG_INCLUDE}/clang-c/")

