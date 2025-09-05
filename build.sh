#!/usr/bin/env bash

nix build --experimental-features "nix-command flakes" .#CI
