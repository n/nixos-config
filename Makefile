.PHONY: switch boot-and-reboot gc optimise fix-git-on-mini

switch:
ifeq ($(shell uname), Darwin)
	sudo -H nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .
else
	sudo nixos-rebuild switch --flake .
endif

boot-and-reboot:
ifeq ($(shell uname), Darwin)
	$(error boot-and-reboot target is only supported on NixOS)
else
	sudo nixos-rebuild boot --flake .
	sudo reboot
endif

gc:
	rm -rf $$HOME/.cache/direnv/layouts
	sudo nix-collect-garbage -d
	nix-collect-garbage -d

optimise:
	nix store optimise

fix-git-on-mini:
	sudo -H git config --global --add safe.directory /Volumes/Home/local/sync/n/nixos-config
