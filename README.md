# v4watch

`v4watch` is a POSIX-compliant shell script for monitoring specific `v4l2-ctl` configuration settings on a video device. It highlights specified settings, allows customization of device paths, and can exclude certain fields from the output for a streamlined view.

## Features

- Monitors a specific `v4l2-ctl` configuration setting using `watch`.
- Highlights the specified setting in green and its `value` in cyan.
- Optionally displays hexadecimal field values and types.
- Allows ignoring specified fields (e.g., `default`, `step`, `flags`).
- Customizable update interval.
- Provides device selection and other customizable options.

## Requirements

- `v4l2-ctl`: Installed as part of the `v4l-utils` package.
- `watch`: Typically pre-installed in most Unix-like environments.

## Installation

To use `v4watch`, save the script as `v4watch.sh`, make it executable, and optionally add it to your system’s PATH.

```bash
# Clone the repository
git clone https://github.com/addyh/v4watch.git
cd v4watch

# Make the script executable
chmod +x v4watch.sh

# Optionally, move it to a directory in your PATH for easy use
mv v4watch.sh /usr/local/bin/v4watch
```

## Usage

```bash
v4watch <config_setting> [--device=<device_path> | -d <device_path>] [--ignore=<fields_to_ignore> | -i <fields_to_ignore>] [--show-hex | -x] [--interval=<seconds> | -t <seconds>]
```

### Arguments

- `<config_setting>`: The `v4l2-ctl` config setting to monitor (e.g., `exposure_time_absolute`, `auto_exposure`).
- `-h, --help`: Display help information.
- `-v, --version`: Display version information.
- `--device=<device_path>, -d <device_path>`: Specify the device path to monitor (e.g., `/dev/video1`).
- `--ignore=<fields_to_ignore>, -i <fields_to_ignore>`: Comma-, space-, or `|`-separated list of fields to ignore in the output (e.g., `default,step,flags`).
- `--show-hex, -x`: Show hexadecimal values and field types in the output.
- `--interval=<seconds>, -t <seconds>`: Set the update interval for `watch` (default is 0.1 seconds).

### Examples

```bash
# Monitor the exposure_time_absolute setting on /dev/video1, ignoring default and step fields
v4watch exposure_time_absolute --device=/dev/video1 --ignore="default,step"

# Alternative syntax for device and ignore options, showing hex values and setting an interval
v4watch exposure_time_absolute -d /dev/video1 -i "default step" -x -t 0.5

# Monitor auto_exposure setting with hex values shown and a 1-second interval update rate
v4watch auto_exposure -x --interval=1
```

## Notes

- Hexadecimal values and parameter types are hidden by default; use `--show-hex` or `-x` to display them.
- Fields specified in the `--ignore` option (e.g., `default`, `step`, `flags`) will be excluded from the output.
- The update interval defaults to `0.1` seconds but can be customized with `--interval` or `-t`.

## Version

`v4watch version 1.2`

## License

This project is licensed under the GPL-3.0 License. See the [LICENSE](LICENSE) file for details.

## Contributing

Pull requests are welcome! For major changes, please open an issue to discuss the proposed changes.

## Contact

For questions or suggestions, please open an issue in the repository.
