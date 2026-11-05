{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "compact";
    };
  };
}
