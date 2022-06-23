{ autoPatchelfHook
, curl
, dpkg
, dbus
, fetchurl
, lib
, libnl
, udev
, cryptsetup
, stdenv
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "twingate";
  version = "1.0.39.44791";	#add comment

  src = fetchurl {
    url = "https://binaries.dev.opstg.com/client/linux/DEB/${version}/twingate-amd64.deb";	#add comment
    sha256 = "b75dd74627582821d2097024cf4624e2f86d69b8ef6d92f2b9983fc0c628513a";	#add comment
  };

  buildInputs = [ curl libnl udev cryptsetup ];
  nativeBuildInputs = [ dbus dpkg autoPatchelfHook ];

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
