with import <nixpkgs> {};

stdenvNoCC.mkDerivation {
  name = "notion_to_gdrive";
  buildInputs = [ elixir pandoc ];

  shellHook = ''
    mix local.hex --force
    mix local.rebar --force
    mix deps.get
  '';
}
