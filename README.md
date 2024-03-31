# Emudeck_SMB_Saves
A small batch of scripts that enables syncing of saves between your Steam Deck (or other Linux device) and a local SMB share.

Due to the complexity of Emudeck's save structure, I made a set of scripts and services that follows all the symlinks to push/pull saves from the right places.

It's intended to pull network saves on Deck startup, and sync your saves to the network every 15 minutes.

Assumes you have a network storage mounted already - if you don't, here's the line I added to my `/etc/fstab` (yours may vary based on user permissions, etc.):

Uses `rsync -avhu`, which basically means it will overwrite a save if the one being pushed/pulled is newer.

```
//<server_name>.local/Games /mnt/<server_name> cifs guest,iocharset=utf8,nofail,_netdev 0 0
```

On the Deck this mounts my folder to `/var/mnt/<server_name>` for some reason, I'm not sure why, but keep in mind that there may be a discrepancy there.

**I've only tested this a bit, it works for me, but I take no responsibility for anything that breaks if you choose to use this!**

Steps:

1. Run `generate_nas_to_deck.sh` and `generate_deck_to_nas.sh`
2. Put the newly created `nas_to_deck.sh` and `deck_to_nas.sh` in `/home/deck/Emulation/` on your Steam Deck
3. Put `startup_network_save_pull.service`, `timed_network_save_push.service`, and `timed_network_save_push.timer` in `/etc/systemd/system/`
4. Run `sudo systemctl daemon-reload`
5. Run `udo systemctl enable startup_network_save_pull.service`
6. Run `sudo systemctl enable timed_network_save_push.timer`

You should now be pulling saves from your network drive on startup, and pushing them every 15 minutes!

Note: I can't get `shutdown_network_save_push.service` to work on shutdown, it doesn't even execute, not sure what the reason is. Keeping it here for later debugging.

Another note: I've got `/home/deck/Emulation/roms` symlinked to `/var/mnt/server_name>/Emulation/roms`, which is also great because I don't have to move games between systems anymore:
```
ln -s /var/mnt/server_name>/Emulation/roms /home/deck/Emulation/roms 
```

To do: Set up a startup/timer script that works with Windows
