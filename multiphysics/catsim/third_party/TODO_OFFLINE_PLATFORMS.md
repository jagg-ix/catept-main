# TODO: populate wheelhouse for additional platforms

The wheelhouse layout supports offline installs across major platforms:

`third_party/wheelhouse/<platform>/<python_tag>/`

Right now, some subfolders may be empty placeholders.

## Platforms to populate later
- macOS Intel: `macos_x86_64`
- macOS Apple Silicon: `macos_arm64`
- Windows Intel/AMD64: `windows_x86_64`
- Additional Python versions: `cp311`, `cp312` as needed

## How to populate (automation provided)
On any **internet-connected** machine:

```bash
make fetch_wheelhouse_matrix
make verify_wheelhouse_checksums
```

Then you can zip/copy the repo to an offline machine and run:

```bash
make install_offline_wheels_with_requirements
```
