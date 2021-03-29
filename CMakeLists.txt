cmake_minimum_required(VERSION 3.19)

PROJECT(Microkernel C ASM)

# Set filename to generate
SET (OUTNAME "ukernel.bin")

# Set the appropriate non-linux-specific compilers,
# init.c will throw an error when compiled for linux
SET (CMAKE_CXX_COMPILER "i686-elf-g++")
SET (CMAKE_C_COMPILER "i686-elf-gcc")
SET (CMAKE_ASM_COMPILER "i686-elf-as")

# Set linker
SET (CMAKE_LINKER "i686-elf-ld")

# Define extentions for assembly files
SET (CMAKE_ASM_SOURCE_FILE_EXTENSIONS ".s" ".asm")

# Set flags for the compiler, assembler and possibly linker
SET (CMAKE_C_FLAGS "-std=gnu99 -ffreestanding -O2 -Wall -Wextra -c")
SET (CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fno-exceptions -fno-rtti")
#SET (CMAKE_LD_FLAGS "")

# Add search directories
LINK_DIRECTORIES ("lib/")

# This overrides the default ASM configuration and passes more sensible args
SET (CMAKE_ASM_COMPILE_OBJECT "<CMAKE_ASM_COMPILER> -o <OBJECT> <SOURCE>")

# Set the CMake environment var for cross compilation
SET (CMAKE_CROSSCOMPILING TRUE)

# Make sure we have an objects directory
MAKE_DIRECTORY ("obj")

SET (SOURCES
  src/bootstrap.asm
  src/kernel/init.s
)

ADD_LIBRARY (kernelobjs ${SOURCES})

SET_TARGET_PROPERTIES (kernelobjs
  PROPERTIES
    RULE_LAUNCH_LINK
      "${PROJECT_SOURCE_DIR}/src/shell/collect.sh ${CMAKE_SOURCE_DIR}/obj <OBJECTS> --"
)

ADD_CUSTOM_TARGET (link
  COMMAND
    ${PROJECT_SOURCE_DIR}/src/shell/link.sh ${OUTNAME}
  DEPENDS
    kernelobjs
  COMMENT
    "Linking kernel"
)

ADD_CUSTOM_TARGET (createiso
  COMMAND
    ${PROJECT_SOURCE_DIR}/grub/generate_iso.sh ${OUTNAME} ${PROJECT_SOURCE_DIR}
  DEPENDS
    link
  COMMENT
    "Generating ISO image"
)

ADD_CUSTOM_TARGET (deepclean
  COMMAND
    ${PROJECT_SOURCE_DIR}/src/shell/deepclean.sh ${PROJECT_SOURCE_DIR}
  DEPENDS
    kernelobjs
  COMMENT
    "Deep cleaning generated files"
)
