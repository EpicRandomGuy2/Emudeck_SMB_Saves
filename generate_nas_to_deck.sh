#!/bin/bash

# This script generates a bash script based on the contents of your saves folder.
# It generates one rsync per symlinked save folder, and a final one for the save folder itself

# The generated script, nas_to_deck.sh, will be set to run on a cadence later.

NETWORK_STORAGE_PATH="<YOUR_NETWORK_STORAGE_PATH>" # Your network storage path, probably something like /var/mnt/<folder> or /mnt/<folder>
SOURCE_DIR="/home/deck/Emulation/saves" # Hardcoded because this is just where the folder lives on a default Emudeck install, change it if needed
DEST_DIR="$NETWORK_STORAGE_PATH/Emulation/saves"  # Copies the folder structure of Emudeck 

# Needed for Network Storage > Steam Deck pull, so symlinks don't get overwritten
EXCLUDES_FILE="$NETWORK_STORAGE_PATH/Emulation/excludes.txt" 
touch "$EXCLUDES_FILE"

# Begin script generation
echo "#!/bin/bash" > nas_to_deck.sh
# Mount the network storage because on startup, it's not guaranteed the storage is mounted yet - if it is, this line will just error harmlessly
echo "mount $NETWORK_STORAGE_PATH" > nas_to_deck.sh

# Find all symlinks and generate rsync commands
find "$SOURCE_DIR" -type l | while read -r symlink; do

  # Determine the relative path of the symlink from the source directory
  relative_path="${symlink#$SOURCE_DIR/}"
  
  # Determine the target of the symlink
  target=$(readlink "$symlink")
  
  # Append symlink path to excludes file to ensure we don't overwrite the symlinks on the deck
  echo "$relative_path" >> "$EXCLUDES_FILE"

  # Echo the directory being synced
  echo "echo \"Syncing from: $DEST_DIR/$relative_path/$target/\"" >> nas_to_deck.sh
  echo "echo \"Syncing to: $target/\"" >> nas_to_deck.sh
  
  echo "rsync -avhu --no-links \"$DEST_DIR/$relative_path/$target/\" \"$target/\"" >> nas_to_deck.sh
done

echo "rsync -avhu --no-links --exclude-from='$EXCLUDES_FILE' \"$DEST_DIR\" \"$SOURCE_DIR\"" >> nas_to_deck.sh
