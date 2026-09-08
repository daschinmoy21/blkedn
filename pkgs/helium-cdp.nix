# Helium plus localhost CDP so sync-yt-cookies can read decrypted YouTube cookies.
# Bind 9222 to loopback only. Do not open it on the LAN.
{
  symlinkJoin,
  makeWrapper,
  helium,
}:
symlinkJoin {
  inherit (helium) name;
  paths = [helium];
  nativeBuildInputs = [makeWrapper];
  postBuild = ''
    rm -f $out/bin/helium
    makeWrapper ${helium}/bin/helium $out/bin/helium \
      --add-flags "--remote-debugging-address=127.0.0.1" \
      --add-flags "--remote-debugging-port=9222" \
      --add-flags "--remote-allow-origins=*"
  '';
  meta = helium.meta or {};
}
