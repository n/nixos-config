switch:
ifeq ($(shell uname), Darwin)
	sudo -H nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .
else
	sudo nixos-rebuild switch --flake .
endif
	nix store optimise

gc:
	rm -rf $$HOME/.cache/direnv/layouts
	sudo nix-collect-garbage -d
	nix-collect-garbage -d
