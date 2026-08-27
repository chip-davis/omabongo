# Bongo Cat — Omarchy Quattro bar widget

A cat in the Omarchy bar that bounces every time you type.

## Requirements

Keypress detection shells out to `libinput debug-events`, which comes from
a separate package from the `libinput` library Hyprland already depends on:

```sh
sudo pacman -S libinput-tools
```

It also needs your user account in the `input` group:

```sh
sudo usermod -aG input $USER
```

Then log out and back in (or reboot) for the group change to apply. 

## Install (published)

```sh
omarchy plugin add https://github.com/chip-davis/omabongo.git --enable
```