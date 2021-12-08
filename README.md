# clang-format-action

An action to error on any clang-format violations.

Runs `clang-format -n -Werror -style=file $sources`, where `$sources` is a user-defined input.
