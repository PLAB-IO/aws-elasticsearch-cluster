let
  unstable = import <nixos-unstable> {};
in
{ nixpkgs ? import <nixpkgs> {} }:
with nixpkgs; mkShell {
  name="aws-env";
  buildInputs = [
    packer
  ];
  shellHook = ''
    echo "Happy coding :)"
    source .venv/bin/activate
  '';
}
