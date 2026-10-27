# OC-PuppetClient

<p align="center">
  <img src=".github/logo.png" alt="OC-PuppetClient logo" width="128" />
</p>

Bootstrap scripts that install and configure the Puppet agent on Linux
and Windows machines.

## Contents

- `linux`: `bootstrap.sh` and `install.sh` set up proxy settings,
  install Puppet, Facter and Hiera with apt, copy in `puppet.conf` and
  run the agent.
- `windows`: `bootstrap.bat`, `bootstrap.ps1` and `install.ps1`
  install the bundled Puppet 3.4.2 MSI and copy in `puppet.conf`.

The matching server setup is in
[OC-PuppetMaster](https://github.com/dmzoneill/OC-PuppetMaster).

## Tech

- Bash and PowerShell
- Puppet 3

## Usage

On Linux, run `linux/bootstrap.sh` as root. On Windows, run
`windows/bootstrap.bat` as an administrator.

## License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE).
