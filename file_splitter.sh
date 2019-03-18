#!/bin/bash
# Usage
# Splits an import file into multiple parts based on a line count and prepends the import
#  file header to each split file.
# 
# To split a file `./file_splitter.sh file_name.txt 100000`

target_dir="output"

file_integrity_check () {
  # Prepare the split files and the original to be validated
  cat ./$target_dir/split_import_* > reconstituted.txt
  echo $HEADER | cat - reconstituted.txt > tempfile && mv tempfile reconstituted.txt

  original=$(shasum -a 256 $filename.bak | cut -d ' ' -f1)
  reconstitued=$(shasum -a 256 reconstituted.txt | cut -d ' ' -f1)

  # Validate the integrity of the file parts
  if [ $original == $reconstitued ]
  then
    echo "File integrity maintained"
    echo ""
    rm reconstituted.txt
  else
    echo "File integrity lost!"
  fi
}

if [ -z $1 ]
then
  echo "Please pass a target file name as './file_splitter.sh <FILENAME>'"
  exit 1
else
  filename="$1"
fi

if [ -z $2 ]
then
  split_size="100000" # number of lines
else
  split_size="$2"
fi

# Grab the import file headers
read -r HEADER < $filename

# Backup the file
cp $filename "$filename.bak"

# Remove the first line. The header will be added to the top of each file part
tail -n +2 $filename > "$filename.tmp" && mv "$filename.tmp" $filename

mkdir -p $target_dir

# Split the file on the `split_size`
# NOTE: --numeric-suffixes and --additional-suffix command flags are only available on Ubuntu flavors
# If using on Mac use this command instead: `split -l $split_size $filename "./$target_dir/split_import_file_part_"`
# Check the `split` man page for all the options
split -l $split_size --numeric-suffixes --additional-suffix .txt $filename "./$target_dir/split_import_file_part_"

echo "File split successfully"
echo ""
echo "Reconstituting the file and checking integrity. This may take a while..."

file_integrity_check

FILES=./$target_dir/*
for f in $FILES
do
  # Add header to all files
  echo $HEADER | cat - $f > tempfile && mv tempfile $f
done

echo "Done"
echo "You can find a backup of the file at $filename.bak"
