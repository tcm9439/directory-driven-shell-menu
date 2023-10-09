this_file_dir=$(realpath $0 | xargs dirname)
cd $this_file_dir
source ../../src/directory_driven_menu.sh

# The directory to be scanned
dir="./config/"

initMeun $dir "DEMO MENU 1"
openMenu
