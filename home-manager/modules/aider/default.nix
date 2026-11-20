{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.lasse.programs.aider;
in
{

  options.lasse.programs.aider = {
    enable = mkEnableOption "aider with the local LLMs on lamaforge";

    apiBase = mkOption {
      type = types.str;
      default = "http://10.11.12.7:8080/v1";
      description = "OpenAI-compatible endpoint (llama-server router on lamaforge, via WireGuard).";
    };
  };

  config = mkIf cfg.enable {

    home.packages = [ pkgs.aider-chat ];

    # Model names = section names in modules/local-llm (llama-server presets)
    home.file.".aider.conf.yml".text = ''
      openai-api-base: ${cfg.apiBase}
      openai-api-key: none
      model: openai/qwen3-coder-30b
      weak-model: openai/gpt-oss-20b
      edit-format: diff
      auto-commits: false
      attribute-author: false
      attribute-committer: false
      analytics-disable: true
      check-update: false
      show-model-warnings: false
    '';

    # Put the few-shot examples into the system prompt; as fake chat history,
    # local models mistake aider's demo repo (mathweb/flask) for the real one.
    home.file.".aider.model.settings.yml".text = ''
      - name: openai/qwen3-coder-30b
        edit_format: diff
        weak_model_name: openai/gpt-oss-20b
        use_repo_map: true
        examples_as_sys_msg: true
      - name: openai/gpt-oss-20b
        edit_format: diff
        use_repo_map: true
        examples_as_sys_msg: true
    '';

    # Context sizes match ctx-size in the presets; costs are zero (local)
    home.file.".aider.model.metadata.json".text = builtins.toJSON {
      "openai/qwen3-coder-30b" = {
        max_input_tokens = 32768;
        max_output_tokens = 8192;
        input_cost_per_token = 0;
        output_cost_per_token = 0;
        litellm_provider = "openai";
        mode = "chat";
      };
      "openai/gpt-oss-20b" = {
        max_input_tokens = 32768;
        max_output_tokens = 8192;
        input_cost_per_token = 0;
        output_cost_per_token = 0;
        litellm_provider = "openai";
        mode = "chat";
      };
    };

    programs.git.ignores = [ ".aider*" ];
  };

}
