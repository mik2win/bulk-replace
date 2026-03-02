# bulk-replace

A simple CLI tool that bulk-replaces text strings across every file in a directory, writing the results to a new output directory — original files untouched.

Built for the case where you have tens or hundreds of config files that share the same placeholder text and need the real value injected all at once. Works with any plain-text files: WireGuard configs, `.env` templates, INI files, YAML, TOML, and more.

## Features

- **Two modes** — quick inline replacement or a YAML config for multiple substitutions
- **Recursive** — processes files in nested subdirectories, preserving the original tree structure
- **Non-destructive** — always writes to a separate output directory; source files are never modified
- **Zero dependencies** — pure Ruby, nothing outside the standard library at runtime

## Installation

```bash
gem install bulk_replace
```

Or add it to your `Gemfile`:

```ruby
gem "bulk_replace"
```

## Usage

### Inline mode — one replacement

Pass the old and new strings directly on the command line.

```bash
bulk-replace \
  --from "DNS = 8.8.8.8" \
  --to   "DNS = 1.1.1.1" \
  --input  ./configs \
  --output ./configs-new
```

### Config file mode — multiple replacements

Describe all substitutions in a YAML file and pass it with `--config`.

```bash
bulk-replace \
  --config replacements.yml \
  --input  ./configs \
  --output ./configs-new
```

**`replacements.yml`**

```yaml
replacements:
  - from: "PrivateKey = PLACEHOLDER"
    to: "PrivateKey = wOEI9rqqbDwnN8/Bpp/ZkEMEKlMDxVMB8PJHA0XXXXXXX="

  - from: "DNS = 8.8.8.8"
    to: "DNS = 1.1.1.1"

  - from: "Endpoint = 203.0.113.1:51820"
    to: "Endpoint = 203.0.113.99:51820"
```

A fully annotated template is provided in [`replacements.example.yml`](replacements.example.yml).

### All options

| Flag | Description |
|------|-------------|
| `--from TEXT` | Text to find (literal, case-sensitive) |
| `--to TEXT` | Replacement text |
| `--config PATH` | Path to a YAML config file |
| `--input DIR` | Directory containing the source files |
| `--output DIR` | Directory to write the updated files into |

`--config` and `--from`/`--to` are mutually exclusive — use one or the other.

## Example: WireGuard key injection

You generated 50 WireGuard peer configs with a placeholder private key. Now you want to inject the real keys.

```
configs/
  peer01.conf
  peer02.conf
  ...
  peer50.conf
```

Each file contains:

```ini
[Interface]
PrivateKey = PLACEHOLDER
Address    = 10.8.0.1/24
DNS        = 8.8.8.8
```

Run:

```bash
bulk-replace \
  --from "PrivateKey = PLACEHOLDER" \
  --to   "PrivateKey = <your_actual_key>" \
  --input  ./configs \
  --output ./configs-ready
```

Result in `configs-ready/` — all files updated, originals intact.

## Development

```bash
git clone https://github.com/mik2win/bulk-replace
cd bulk-replace
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome at [github.com/mik2win/bulk-replace](https://github.com/mik2win/bulk-replace).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
