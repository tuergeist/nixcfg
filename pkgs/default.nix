final: prev:
let
  inherit (prev) lib callPackage;
in
with lib;
{
#  insync = callPackage ./insync {} ;

  # soapyuhd fails to build against UHD 4.11 in nixpkgs-unstable
  # (upstream API break: get_stream_info became a pure virtual).
  # Rebuild soapysdr-with-plugins without the UHD plugin so gqrx/sdrpp
  # still build. This only drops Ettus/USRP support, not RTL-SDR.
  soapysdr-with-plugins = prev.soapysdr.override {
    extraPackages = with final; [
      limesuite
      soapyairspy
      soapyaudio
      soapybladerf
      soapyhackrf
      soapyplutosdr
      soapyremote
      soapyrtlsdr
    ];
  };
}
