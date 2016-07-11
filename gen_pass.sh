#!/usr/local/bin/zsh

gen_password()
{
    dd if=/dev/urandom count=2000 bs=1 2>/dev/null|\
    LC_ALL=C tr -d -c '[:alnum:]' | cut -b -20
}

