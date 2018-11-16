with import <nixpkgs> {};

stdenvNoCC.mkDerivation {
  name = "notion_to_gdrive";
  buildInputs = [ elixir pandoc ];
}
