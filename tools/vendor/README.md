# Vendored packages

- `libpcre3_8.39-15build1_amd64.deb`: Ubuntu 24.04's libpcre3 (PCRE 8.39, BSD licence; the
  copyright file is inside the package), from
  `archive.ubuntu.com/ubuntu/pool/universe/p/pcre3/`. nimib's markdown loads `libpcre.so` at run
  time, and `tools/setup.sh` installs this copy with dpkg (checking its sha256), so neither CI nor
  a sandbox needs an Ubuntu mirror. It goes when Nim's standard library no longer needs PCRE.
