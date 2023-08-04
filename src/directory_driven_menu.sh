menu_items=()
menu_items_count=0
sub_menu_count=0
current_depth=0
has_back_choice=0

goInTo(){
    cd $1
    current_depth=$((current_depth+1))
}

back(){
    if [ $current_depth -le 0 ]; then
        return
    fi
    cd ..
    current_depth=$((current_depth-1))
}

readOperations(){
    # get all the directory in the directory
    dir_items=$(find . -mindepth 1 -maxdepth 1 -type d)
    menu_items=()
    for item in $dir_items;
    do 
        menu_items+=("Go to sub-menu of "$(basename $item))
    done
    sub_menu_count=${#menu_items[@]}

    # get all the name of the file in the directory
    dir_items=$(find . -maxdepth 1 -type f)
    for item in $dir_items;
    do 
        menu_items+=($(basename $item))
    done

    menu_items_count=${#menu_items[@]}

    if [ $current_depth -gt 0 ]; then
        has_back_choice=1
        menu_items+=("Back")
    else 
        has_back_choice=0
    fi
}

selectOperation(){
    PS3="Select opertation: "
    choice=
    select item in "${menu_items[@]}" Quit
    do
        if [[ $REPLY =~ ^[0-9]+$ ]]; then 
            # REPLY is a number
            if [ $REPLY -le $sub_menu_count ]; then
                # Sub menu
                choice=${menu_items[$((REPLY-1))]}
                is_sub_menu=true
                goInTo $choice
                break
            elif [ $REPLY -le $menu_items_count ]; then
                # operation
                choice=${menu_items[$((REPLY-1))]}
                echo
                echo ----------------------------------
                echo
                ./$choice
                break
            elif [ $REPLY -eq $(($menu_items_count+$has_back_choice)) ]; then
                # Back to last menu
                back
                break
            elif [ $REPLY -eq $(($menu_items_count+$has_back_choice+1)) ]; then
                # Quit the program
                exit 0
            fi
        fi

        echo
        echo ----------------------------------
        echo
        echo ">>> Unknow operation <<<"
        echo
        echo ==================================
        echo
    done

    echo
    echo ==================================
    echo
}

initMeun(){
    current_dir=$(realpath $1)
    cd $current_dir
}

start(){
    while true; do
        readOperations
        selectOperation
    done
}