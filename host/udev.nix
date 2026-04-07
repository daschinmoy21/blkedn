{
  config,
  pkgs,
  ...
}: {
  services.udev.extraRules = ''
    # VGN / VXE Mice (Dragonfly F1, R1, etc.)
    # This allows the browser to access the mouse via WebHID (e.g., VGN Hub)
    
    # Compx VGN Mouse 2.4G Receiver (3554:f503)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f503", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f503", MODE="0660", TAG+="uaccess"

    # CX 2.4G Wireless Receiver (3554:fa09)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="fa09", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="fa09", MODE="0660", TAG+="uaccess"

    # Generic VGN/VXE Vendor ID 362f (Fallback)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="362f", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="362f", MODE="0660", TAG+="uaccess"
  '';
}
