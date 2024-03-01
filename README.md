# Overview

`resize.sh` provides a simple Posix shell script replacement for the base
functionality of the `resize` utility found in the `xterm` sources.

It is sufficient to detect the size of VTxx like terminals (terminal emulators,
these days), set the termios size and output shell commands to set `LINES` and
`COLUMNS` in an `eval` statement.

It is meant to be used on small systems like Raspberry Pis when using the
serial console. `resize` allows a more convenient setup of the terminal during
login. Using this `resize` replacement, the `xterm` package does not need to be
installed to have the `resize` functionality. `xterm` might require a lot of
dependencies, especially when a graphical desktop is not desired.

# How To Use

On Debian like systems, put the following lines in `/etc/profile`:

```
case $(/usr/bin/tty) in
/dev/ttyAMA0)
        eval $(/usr/bin/tset -sw)
        eval $(/usr/bin/resize.sh)
        ;;
esac
```

