{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.lgoette.local-llm;

  # Router-mode presets for llama-server; models are pulled from Hugging Face
  # into /var/cache/llama-cpp on first use. Both are abliterated (huihui-ai).
  modelsPreset = pkgs.writeText "llama-models.ini" ''
    [qwen3-coder-30b]
    hf-repo = mradermacher/Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated-i1-GGUF
    hf-file = Huihui-Qwen3-Coder-30B-A3B-Instruct-abliterated.i1-Q4_K_M.gguf
    ctx-size = 32768
    temp = 0.7
    top-p = 0.8
    top-k = 20
    repeat-penalty = 1.05

    [gpt-oss-20b]
    hf-repo = noctrex/Huihui-gpt-oss-20b-abliterated-v2-MXFP4_MOE-GGUF
    hf-file = Huihui-gpt-oss-20b-abliterated-v2-MXFP4_MOE.gguf
    ctx-size = 32768
    temp = 1.0
    top-p = 1.0
  '';
in
{
  options.lgoette.local-llm = {
    enable = mkEnableOption "local LLMs (llama.cpp router + Open WebUI)";

    llamaPort = mkOption {
      type = types.port;
      default = 8080;
      description = "Port of the OpenAI-compatible llama-server API.";
    };

    webuiPort = mkOption {
      type = types.port;
      default = 3000;
      description = "Port of Open WebUI.";
    };

    interface = mkOption {
      type = types.str;
      default = "wg0";
      description = "Only this interface gets the ports opened in the firewall.";
    };
  };

  config = mkIf cfg.enable {

    services.llama-cpp = {
      enable = true;
      settings = {
        host = "0.0.0.0";
        port = cfg.llamaPort;
        models-preset = modelsPreset;
        models-max = 2;
      };
    };

    services.open-webui = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.webuiPort;
      # Replaces the module default, so keep its telemetry opt-outs.
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        ENABLE_OLLAMA_API = "False";
        OPENAI_API_BASE_URL = "http://127.0.0.1:${toString cfg.llamaPort}/v1";
        OPENAI_API_KEY = "none";
      };
    };

    networking.firewall.interfaces.${cfg.interface}.allowedTCPPorts = [
      cfg.llamaPort
      cfg.webuiPort
    ];
  };
}
