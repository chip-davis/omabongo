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

## Config
Edit / create ~/.config/omabongo/config.json. Supported options:

| Key           | Type   | Default | Controls                           |
|---------------|--------|---------|------------------------------------|
| scale         | number | 2.2     | sprite size multiplier of  barSize |
| sleepAfterMs  | number | 20000   | inactivity time before sleeping    |
| tapDurationMs | number | 110     | how long his paws are down         |
| sleepEnabled  | bool   | true    | controls if bongocat goes to sleep |


## Uninstall
Uninstall with 
```sh
omarchy plugin remove io.github.chip-davis.omabongo
```

## License

MIT — see [LICENSE](LICENSE). The cat sprites in `assets/` are derived from
[wayland-bongocat](https://github.com/saatvik333/wayland-bongocat); see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).