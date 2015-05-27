# Wuppet
## Summary
A script to remotely install Puppet agents on windows machines with PowerShell.  Maybe more stuff coming later.

## Prep for running script
- Create a computers.txt file in the same location as this script.
  - The list should contain the resolvable names of all the machines you intend to remotely install Puppet.
- Put the Puppet MSI installer(s) on a network share that is accessible by the workstation running this script and all target machines.
  - Edit the following variables
    - $networkLocation = The location of the Puppet MSI(s).
    - $64installer     = The full filename of the 64bit MSI 
    - $32installer   = The full filename of the 32bit MSI 
- Optional Variables (When I say optional, I mean optional for the MSI's silent install.  This script as currently written expects to use them.  If not needed you will need to remove them both where they are definted and referenced in the script.)
  - $service_user    = The user to the Puppet service will run as instead of the default 'Local System'.
  - $service_user_pw = The password for the above user.  You will be prompted for this at execution time.
  - $puppetMaster    = The DNS name of the puppet master.
  - $domain          = The Active Directory Domain of which the $service_user is a member.

## Usage
  - Do the relevant prep work above.
  - `.\puppet_agent_remote_install.ps1`

## Notes
  - Line 27 `Get-WmiObject` will take some time (especially when being run on machines with lots of applications installed) because it will parse through everything under Installed Programs to find the Puppet installation.
