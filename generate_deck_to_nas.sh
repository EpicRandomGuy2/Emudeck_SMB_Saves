#!/bin/bash

# This script generates a bash script based on the contents of your saves folder.
# It generates one rsync per symlinked save folder, and a final one for the save folder itself

# The generated script, deck_to_nas.sh, will be set to run on a cadence later.
NETWORK_STORAGE_PATH="<YOUR_NETWORK_STORAGE_PATH>" # Your network storage path, probably something like /var/mnt/<folder> or /mnt/<folder>
SOURCE_DIR="/home/deck/Emulation/saves" # Hardcoded because this is just where the folder lives on a default Emudeck install, change it if needed
DEST_DIR="$NETWORK_STORAGE_PATH/Emulation/saves"

# Begin script generation
echo "#!/bin/bash" > deck_to_nas.sh
# Mount the network storage just in case it's not mounted yet - if it is, this line will just error harmlessly
echo "mount $NETWORK_STORAGE_PATH" > nas_to_deck.sh

# Find all symlinks and generate rsync commands
find "$SOURCE_DIR" -type l | while read -r symlink; do
  # Determine the relative path of the symlink from the source directory
  relative_path="${symlink#$SOURCE_DIR/}"
  
  # Determine the target of the symlink
  target=$(readlink "$symlink")
  
  # Ensure path exists on network storage
  mkdir -p "$DEST_DIR/$relative_path/$target"

  # Echo the directory being synced
  echo "echo \"Syncing from: $symlink\"" >> deck_to_nas.sh
  echo "echo \"Syncing to: $DEST_DIR/$relative_path/$target/\"" >> deck_to_nas.sh

  # Brings the files from the symlink locations into a place where we can drop them back with the correct file structure later
  echo "rsync -avhuL \"$symlink/\" \"$DEST_DIR/$relative_path/$target/\"" >> deck_to_nas.sh
done

echo "rsync -avhu --no-links \"/home/deck/Emulation/saves/\" \"/var/mnt/mnemosyne/Emulation/saves/\"" >> deck_to_nas.sh
