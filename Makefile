SHELL := /bin/zsh

PREFIX ?= $(HOME)/.local
VERSION := $(shell sed -n '1p' VERSION)
DIST_DIR := dist
DIST_NAME := reina-de-copas-$(VERSION)

.PHONY: help syntax test install uninstall dist clean

help:
	@print -- "Targets:"
	@print -- "  make syntax      valida sintaxis zsh"
	@print -- "  make test        corre pruebas locales"
	@print -- "  make install     instala en PREFIX=$(PREFIX)"
	@print -- "  make uninstall   desinstala de PREFIX=$(PREFIX)"
	@print -- "  make dist        genera tarball en dist/"
	@print -- "  make clean       limpia artefactos locales"

syntax:
	@zsh -c 'setopt nullglob; files=(bin/reina lib/core/*.zsh lib/services/*.zsh lib/presets/*.zsh lib/presets/*/*.zsh scripts/*.zsh tests/*.zsh); zsh -n "$$files[@]"'

test: syntax
	@zsh tests/smoke_reina.zsh
	@zsh tests/preset_dispatcher.zsh
	@zsh tests/presets_bass.zsh
	@zsh tests/presets_low_end.zsh
	@zsh tests/presets_vocals_atmospheric.zsh
	@zsh tests/presets_female_vocal.zsh
	@zsh tests/presets_vocal_utility.zsh
	@zsh tests/presets_drum_bus.zsh
	@zsh tests/presets_drum_experimental.zsh
	@zsh tests/presets_drum_pieces_core.zsh
	@zsh tests/presets_drum_detail_and_space.zsh
	@zsh tests/presets_guitar_heavy_and_electric.zsh
	@zsh tests/presets_guitar_acoustic.zsh
@zsh tests/presets_keys_and_piano.zsh
	@zsh tests/errors_service.zsh
	@zsh tests/network_service.zsh
	@zsh tests/storage_service.zsh
	@zsh tests/distribution_install.zsh

install:
	@PREFIX="$(PREFIX)" zsh scripts/install.zsh

uninstall:
	@PREFIX="$(PREFIX)" zsh scripts/uninstall.zsh

dist: clean
	@mkdir -p "$(DIST_DIR)/$(DIST_NAME)"
	@cp -R bin docs lib presets scripts tests README.md VERSION Makefile .gitignore "$(DIST_DIR)/$(DIST_NAME)/"
	@tar -C "$(DIST_DIR)" -czf "$(DIST_DIR)/$(DIST_NAME).tar.gz" "$(DIST_NAME)"
	@rm -rf "$(DIST_DIR)/$(DIST_NAME)"
	@print -- "$(DIST_DIR)/$(DIST_NAME).tar.gz"

clean:
	@rm -rf "$(DIST_DIR)"
