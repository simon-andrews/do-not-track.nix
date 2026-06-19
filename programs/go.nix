{ config, ... }:
{
  enable = config.programs.go.enable;
  settings.programs.go.telemetry.mode = "off";
  references = [ "https://go.dev/doc/telemetry" ];
}
