cfg() {
 (: ${build:=`gcc -dumpmachine`}
  : ${host:=$build}
  : ${prefix:=/usr${host:+/$host}}

  CROSS_COMPILE=${host:+$host-}

  : ${builddir:=build/${host:-$build}}

  mkdir -p $builddir 
  relsrcdir=`realpath --relative-to="$builddir" "$(pwd)"`

  set -x;
  cd $builddir

  "$relsrcdir"/configure \
      --prefix="$prefix" \
      ${bindir:+--bindir="$bindir"} \
      ${libdir:+--libdir="$libdir"} \
      --disable-{maintainer-mode,silent-rules,libtool-lock} \
      ${build:+--build="$build"} \
      ${host:+--host="$host"} \
      ${target:+--target="$target"} \
      --disable-{nls,rpath,assert} \
      --enable-libmount \
    "$@")
}

android-cfg() {
  host="arm-linux-androideabi"
  build="$(gcc -dumpmachine)"
  prefix="/opt/$host/sysroot/usr"
  builddir="build/android"

  PKG_CONFIG_PATH="$prefix/lib/pkgconfig:$prefix/share/pkgconfig:$prefix/lib/pkgconfig" \
  PKG_CONFIG_LIBDIR="$prefix/lib/pkgconfig" \
  PKG_CONFIG="$host-pkg-config" \
  CC="$host-gcc --sysroot=/opt/$host/sysroot" \
  CXX="$host-g++ --sysroot=/opt/$host/sysroot" \
  CFLAGS="-fPIE" CPPFLAGS="-fPIE" CXXFLAGS="-fPIE" LDFLAGS="-pie"  \
  CPPFLAGS="-D__ANDROID_API__=24 -I$prefix/include -I/system/include" \
  cfg \
    "$@"
}

termux-cfg() {
  host="arm-linux-androideabi"
  build="$(gcc -dumpmachine)"
  prefix="/data/data/com.termux/files/usr"
  builddir="build/termux"

  PKG_CONFIG_PATH="$prefix/lib/pkgconfig:$prefix/share/pkgconfig:/opt/$host/sysroot/usr/lib/pkgconfig" \
  PKG_CONFIG_LIBDIR="$prefix/lib/pkgconfig" \
  PKG_CONFIG="$host-pkg-config" \
  CC="$host-gcc --sysroot=/data/data/com.termux/files" \
  CXX="$host-g++ --sysroot=/data/data/com.termux/files" \
  CFLAGS="-fPIE" CPPFLAGS="-fPIE" CXXFLAGS="-fPIE" LDFLAGS="-pie"  \
  CPPFLAGS="-D__ANDROID_API__=24 -I$prefix/include -I/data/data/com.termux/files/system/include" \
  cfg \
    "$@"
}

diet-cfg() {
 (build=$(${CC:-gcc} -dumpmachine)
  host=${build/-gnu/-dietlibc}
  prefix=/opt/diet
  libdir=/opt/diet/lib-${host%%-*}
  bindir=/opt/diet/bin-${host%%-*}

  CC="diet-gcc" \
  CPPFLAGS="-D_{BSD,XOPEN,POSIX,GNU,ATFILE}_SOURCE=1" \
  PKG_CONFIG="$host-pkg-config" \
  cfg \
    --disable-shared \
    --enable-static \
    "$@")
}

musl-cfg() {
 (build=$(${CC:-gcc} -dumpmachine)
  host=${build/-gnu/-musl}
  host=${host/-pc-/-}
  builddir=build/$host
  prefix=/usr
  includedir=/usr/include/$host
  libdir=/usr/lib/$host
  bindir=/usr/bin/$host

  CC="musl-gcc" \
  PKG_CONFIG="musl-pkg-config" \
  cfg \
    --disable-shared \
    --enable-static \
    "$@")
}
