defmodule DNScreen.MixProject do
  use Mix.Project

  def project do
    [
      app: :notion_to_gdrive,
      version: "0.0.0",
      deps: [
        briefly: "~> 0.3",
        config_macro: "~> 0.1",
        elixir_uuid: "~> 1.2",
        google_api_drive: "~> 0.1",
        goth: "~> 0.9",
        httpoison: "~> 1.2",
        poison: "~> 3.1"
      ]
    ]
  end

  def application do
    [mod: {NotionToGDrive, []}]
  end
end
