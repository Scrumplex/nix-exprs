{
  lib,
  stdenv,
  symlinkJoin,
  modrinth-app-unwrapped,
  wrapGAppsHook,
  flite,
  glib-networking,
  glfw,
  jdk8,
  jdk17,
  jdks ? [jdk8 jdk17],
  libGL,
  libpulseaudio,
  openal,
  xorg,
}: let
  final = modrinth-app-unwrapped;
in
  symlinkJoin {
    name = "modrinth-app-${final.version}";

    paths = [final];

    nativeBuildInputs = [
      wrapGAppsHook
    ];

    preFixup = let
      libPath = lib.makeLibraryPath ([
          flite
          glfw
          libGL
          libpulseaudio
          openal
          stdenv.cc.cc.lib
        ]
        ++ (with xorg; [
          libX11
          libXcursor
          libXext
          libXxf86vm
          libXrandr
        ]));
      binPath = lib.makeBinPath (lib.optionals stdenv.isLinux [xorg.xrandr] ++ jdks);
    in ''
      gappsWrapperArgs+=(
        ${lib.optionalString stdenv.isLinux "--set LD_LIBRARY_PATH /run/opengl-driver/lib:${libPath}"}
        ${lib.optionalString stdenv.isLinux "--prefix GIO_MODULE_DIR : ${glib-networking}/lib/gio/modules/"}
        --prefix PATH : ${binPath}
      )
    '';

    inherit (final) meta;
  }
