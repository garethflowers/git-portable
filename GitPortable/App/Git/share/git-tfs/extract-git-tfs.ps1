param([string]$path)

# You can download the latest git-tfs. zip file at https://github.com/git-tfs/git-tfs/downloads
if ($path -eq "" -or !(test-path $path)) {
  write-host "Usage: extract-git-tfs ""path-to-git-tfs.zip"""
  exit 1
}

# Get to the root of the git repository
$dir = split-path $MyInvocation.MyCommand.Definition
$share = split-path $dir
$root = split-path $share
pushd $root

# Remove the old version of git-tfs.
git rm -q -r $dir
if (!$?) {
  write-host "Could not remove previous version of git-tfs."
  popd
  exit 1
}
git reset -q HEAD -- share/git-tfs/extract-git-tfs.ps1
git checkout -q HEAD -- share/git-tfs/extract-git-tfs.ps1

# Extract the new git-tfs.
$shell = new-object -com shell.application
$zip = $shell.namespace((convert-path $path))
$destination = $shell.namespace($dir)
$destination.Copyhere($zip.items())

# Clean up the distribution.
rm "$dir\*.pdb" -force

# Add the files and show them.
git add $dir
git status $dir

write-host "Extracted $path."
popd
