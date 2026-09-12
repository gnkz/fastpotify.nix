{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  cmake,
  makeWrapper,
  alsa-lib,
  libpulseaudio,
  libGL,
  libxkbcommon,
  wayland,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  versionCheckHook,
  libprojectm,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastpotify";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "crmne";
    repo = "fastpotify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RZEM1b7oj0dAIXKf+B4z5g8RaO9lArMk04/h++roGME=";
  };

  cargoHash = "sha256-DrwPRPGr2QBXpTKJmCSHLnOJAymwuN7SKKqEYlNTQHc=";

  nativeBuildInputs = [
    pkg-config
    cmake
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    libpulseaudio
    libGL
    libx11
    libprojectm
  ];

  postPatch = ''
         # projectm-sys searches only $out/lib, but CMake defaults to lib64 on NixOS.
         substituteInPlace "$cargoDepsCopy"/source-*/projectm-sys-*/build.rs \
           --replace-fail '.define("ENABLE_PLAYLIST", enable_playlist_flag)' \
             '.define("CMAKE_INSTALL_LIBDIR", "lib").define("ENABLE_PLAYLIST",
    enable_playlist_flag)'
  '';

  postInstall = ''
    install -Dm644 packaging/applications/fastpotify.desktop \
      $out/share/applications/fastpotify.desktop
    install -Dm644 packaging/icons/fastpotify.svg \
      $out/share/icons/hicolor/scalable/apps/fastpotify.svg
  '';

  postFixup = ''
    wrapProgram $out/bin/fastpotify \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libxkbcommon
          wayland
          libGL
          libx11
          libxcursor
          libxi
          libxrandr
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Fast native Spotify client with local playback and Spotify Connect";
    homepage = "https://fastpotify.rocks";
    changelog = "https://github.com/crmne/fastpotify/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "fastpotify";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" ];
  };
})
