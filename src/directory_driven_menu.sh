menu_items=()               # the menu items to be displayed
menu_items_files=()         # the file / dir name of the menu items
menu_items_count=0          # the total number of menu items
sub_menu_count=0            # the total number of sub menu items
current_depth=0             # the current depth of the menu
has_back_choice=0           # whether the menu has a back choice
current_title="Menu"        # the current menu title

TITLE_FORMAT='\033[96;1;4m'
PROMT_FORMAT='\033[94m'
ERROR_FORMAT='\033[31m'
GREEN_FORMAT='\033[32m'
CLOSE_FORMAT='\033[0m'

pushTitle(){ 
    let title_stack_count++
    eval "title_item$title_stack_count=\"$1\""
}

peekTitle(){ 
    eval "echo \$title_item$title_stack_count"
}

popTitle(){ 
    eval "echo \$title_item$title_stack_count;unset title_item$title_stack_count"
    let title_stack_count--
}

clearScreen(){
    clear
}

pause(){
    DUMMY=0
    read -p "Press [Enter] key to continue..." DUMMY
}

# go into a sub menu
# goInTo <directory> <menu name>
goInTo(){
    pushTitle "$2"
    cd $1
    current_depth=$((current_depth+1))
}

# go back to the last menu
back(){
    if [ $current_depth -le 0 ]; then
        return
    fi
    cd ..
    current_depth=$((current_depth-1))

    # get the last title
    popTitle >> /dev/null # pop the current title
    current_title=$(popTitle)
}

# load the menu items from the current directory
readOperations(){
    menu_items=()
    menu_items_files=()

    # get all the directory in the directory
    dir_items=$(find . -mindepth 1 -maxdepth 1 -type d)
    for item in $dir_items;
    do 
        file_name=$(basename $item)
        menu_items_files+=($file_name)
        menu_items+=("$(echo $file_name | sed -r 's/-/ /gi')")
    done
    
    # get the number of sub menu items
    sub_menu_count=${#menu_items[@]}

    # get all the name of the file in the directory
    dir_items=$(find . -maxdepth 1 -type f)
    for item in $dir_items;
    do 
        file_name=$(basename $item)
        menu_items_files+=($file_name)
        menu_items+=("$(echo $file_name | sed -r 's/.sh//gi' | sed -r 's/-/ /gi')")
    done

    # get the total number of menu items
    menu_items_count=${#menu_items[@]}

    # check if the menu has a back choice
    if [ $current_depth -gt 0 ]; then
        has_back_choice=1
        menu_items+=("Back")
    else 
        has_back_choice=0
    fi
}

# print the menu and let the user select an operation
selectOperation(){
    current_title=$(peekTitle)
    printf $TITLE_FORMAT"$current_title\n\n"$CLOSE_FORMAT

    printf $PROMT_FORMAT
    PS3="Select opertation: "
    choice=
    select item in "${menu_items[@]}" Quit
    do
        printf $CLOSE_FORMAT
        if [[ $REPLY =~ ^[0-9]+$ ]]; then 
            # REPLY is a number
            if [ $REPLY -le $sub_menu_count ]; then
                # Sub menu
                clearScreen
                choice=${menu_items_files[$((REPLY-1))]}
                choice_name=${menu_items[$((REPLY-1))]}
                goInTo $choice $choice_name
                break
            elif [ $REPLY -le $menu_items_count ]; then
                # operation
                clearScreen
                choice=${menu_items_files[$((REPLY-1))]}
                ./$choice
                echo
                pause
                clearScreen
                break
            elif [ $REPLY -eq $(($menu_items_count+$has_back_choice)) ]; then
                # Back to last menu
                clearScreen
                back
                break
            elif [ $REPLY -eq $(($menu_items_count+$has_back_choice+1)) ]; then
                # Quit the program
                clearScreen
                printf $GREEN_FORMAT"Menu Closed\n"$CLOSE_FORMAT
                exit 0
            fi
        fi
        printf $ERROR_FORMAT"ERROR: Unknow operation\n"$CLOSE_FORMAT
        printf $PROMT_FORMAT
    done
}

initMeun(){
    current_dir=$(realpath $1)
    pushTitle "$2"
    cd $current_dir
}

openMenu(){
    clearScreen
    while true; do
        readOperations
        selectOperation
    done
}
