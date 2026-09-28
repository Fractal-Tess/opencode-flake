{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  ripgrep,
}:

let
  version = "1.18.33";
  sources = {
    x86_64-linux = {
      asset = "opencode-linux-x64.tar.gz";
      hash = "sha256-5UYSMhOuR5CaQmhpKqS5SVDQEa/pysmTh1OiGU8cFtU=";
    };
    aarch64-linux = {
      asset = "opencode-linux-arm64.tar.gz";
      hash = "sha256-xjSGYkYhkkv0O+XAGr0lKIVmGnNIFCJPbXAYijOuqFg=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "opencode";
  inherit version;

  src = fetchurl {
    url = "https://github.com/sst/opencode/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # The Bun-compiled binary links only against glibc (libc, libm, libpthread,
  # libdl), which autoPatchelfHook resolves from the stdenv; no extra
  # buildInputs are needed.

  sourceRoot = ".";

  # The binary is a Bun single-file executable with a compressed payload
  # appended; stripping it breaks execution.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 opencode "$out/bin/opencode"
    runHook postInstall
  '';

  # opencode shells out to ripgrep for search instead of vendoring it.
  postFixup = ''
    wrapProgram "$out/bin/opencode" \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
  '';

  meta = {
    description = "AI coding agent built for the terminal";
    homepage = "https://github.com/sst/opencode";
    changelog = "https://github.com/sst/opencode/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
