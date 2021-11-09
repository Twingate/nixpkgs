{ autoPatchelfHook
, curl
, dpkg
, dbus_daemon
, fetchurl
, lib
, libnl
, libudev
, stdenv
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "twingate";
  version = "1.0.12";

  src = fetchurl {
    url = "https://binaries.twingate.com/client/linux/DEB/${version}/twingate-amd64.deb";
    sha256 = "c9865fe6af150580b6d9541c1cb7d6205aa2afe97395dc37b10ba92067c6b935";
  };

  buildInputs = [ curl libnl libudev ];
  nativeBuildInputs = [ dbus_daemon.dev dpkg autoPatchelfHook ];

  unpackCmd = "mkdir root ; dpkg-deb -x $curSrc root";

  postPatch = ''
    while read file; do
      substituteInPlace "$file" \
        --replace "/usr/bin" "$out/bin" \
        --replace "/usr/sbin" "$out/bin"
    done < <(find etc usr/lib usr/share -type f)
  '';

  installPhase = ''
    mkdir $out
    mv etc $out/
    mv usr/bin $out/bin
    mv usr/sbin/* $out/bin
    mv usr/lib $out/lib
    mv usr/share $out/share
  '';

  meta = with lib; {
    description = "Twingate Client";
    homepage = "https://twingate.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ tonyshkurenko ];
    platforms = platforms.linux;
  };
}
