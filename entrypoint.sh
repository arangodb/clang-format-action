#!/bin/sh
cd "$GITHUB_WORKSPACE" || exit 2
if [ -z "$INPUT_SOURCES" ]
then
    echo "Input is empty. Skipping Action."
else
    echo "-----------"
    clang-format --version
    echo "-----------"
    echo "clang-format -n -Werror -style=file $INPUT_SOURCES"
    echo "-----------"
    clang-format -n -Werror -style=file $INPUT_SOURCES
    echo "erledigt"
fi