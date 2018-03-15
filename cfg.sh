defaultcfg() {
  (set -x;   cfg --enable-debug --enable-libmount   --disable-{shared,nls,rpath,assert}   --without-python  --disable-pylibmount)
}

cfg () 
{ 
    IFS="
 $IFS"
    : ${build=$(${CC-gcc} -dumpmachine | sed "s/-pc-/-/ ;; s/linux/pc-&/")}
    : ${host=$build}
    : ${builddir=build/$build}
    : ${prefix=/usr}

     #export PKG_CONFIG_PATH="$prefix/lib/pkgconfig:$prefix/share/pkgconfig"
     export LIBS="-ldl"

    mkdir -p $builddir;
    #relsrcdir=$(realpath --relative-to="$builddir" $PWD)
    relsrcdir=../..
    ( set -x; cd $builddir;
    "$relsrcdir"/configure \
          --prefix=$prefix \
          --disable-{silent-rules,dependency-tracking,libtool-lock} \
           --enable-libmount \
          "$@"
    )

}


dietcfg() {
    IFS="
 $IFS"
    build=$(${CC-gcc} -dumpmachine | sed "s/-pc-/-/ ;; s/linux/pc-&/")
    cfg32
   
    
    host=${build//-pc-/-}; host=${host#*-}; host=$a-${host//-gnu*/-dietlibc}
    builddir=build/$host

    case "$host" in 
        *-diet*) prefix=/opt/diet ;;
        *) prefix=/usr ;;
    esac

    export LIBS="-lcompat -lpthread"
    export PKG_CONFIG_PATH=/opt/diet/lib-$cpu/pkgconfig
    libdir="$prefix/lib-$cpu"

    CC="/opt/diet/bin-$cpu/diet -Os ${CC:-gcc} -D_BSD_SOURCE=1 -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 -D_SC_HOST_NAME_MAX=180" \
    cfg \
      ${libdir+--libdir=$libdir} \
     --bindir=$prefix/bin-$cpu \
      --disable-shared \
      --enable-static \
      "$@"
}


cfg32() {
  case "$CC $*" in
      *-m32*) host=i686-${host#*-} cpu=x86_64 ;;
      *i[3-6]86*) host=i686-${host#*-} cpu=i386 ;;
  esac
  case "$host" in
    i?86*) a=i686 cpu=i386 m="-m32" l="32" ;;
    *) a=x86_64 cpu=x86_64 m="-m64" l="" ;;
  esac
}


cfg32() {
  case "$CC $*" in
      *-m32*) host=i686-${host#*-} cpu=x86_64 ;;
      *i[3-6]86*) host=i686-${host#*-} cpu=i386 ;;
      *) host=$(${CC-gcc} -dumpmachine); cpu=${host%%-*} ;;
  esac
  case "$host" in
    i?86*) a=i686 cpu=i386 m="-m32" l="32" ;;
    *) a=x86_64 cpu=x86_64 m="-m64" l="" ;;
  esac
}

