`su -` . . . . . . . . . . . . . . . . Switch to root user

`groups` . . . . . . . . . . . . . . . List groups
`getent group <groupname>` . . . . . . List <groupname> users
`sudo whoami`. . . . . . . . . . . . . Check user status

`sudo usermod -aG <groupname> $USER` . Add user to group

To give superuser privileges:

1. Switch to root user
2. Add <user_name> to sudo group: `usermod -aG sudo <user_name>`
3. Check sudoers file: 
 - `sudo visudo`
 - add line: `%sudo	ALL=(ALL:ALL) ALL` (Any user who is in the sudo group can execute any command as any user)
				
