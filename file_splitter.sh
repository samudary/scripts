#!/bin/bash
# Usage
# Make the file executable: `chmod u+x file_splitter.sh`
# Split a file `./file_splitter.sh file_name.txt 100000`

target_dir="destination"

if [ -z $1 ]
then
  echo "Please pass a target file name as 'file_splitter.sh <FILENAME>'"
  exit 1
else
  filename="$1"
fi

if [ -z $2 ]
then
  split_size="100000"
else
  split_size="$2"
fi

read -r HEADER < $filename
echo "Import file headers: $HEADER"

mkdir -p $target_dir

# Split the file on the `split_size`
split -l $split_size $filename "./$target_dir/split_import_file_part_"

# Prepare the split files and the original to be validated
cat ./$target_dir/split_import_* > reconstituted.txt
original="$(cat $filename | md5)"
reconstitued="$(cat reconstituted.txt | md5)"

# Validate the integrity of the file parts
if [ $original == $reconstitued ]
then
  echo "File integrity maintained"
  echo "File split successfully"
fi
