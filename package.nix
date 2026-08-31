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
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastpotify";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "crmne";
    repo = "fastpotify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z/g5T2qR7nyBbxeSDEJ8GVRkyrkX/6F6GOLUa7lvgMM=";
  };

  cargoHash = "sha256-JBU8IhhJDZeXu6F/oSwMYTyYwXLBFz25POpQnMbtjrg=";

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
  ];

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
