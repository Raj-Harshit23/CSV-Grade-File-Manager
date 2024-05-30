#!/usr/bin/env bash

#git2 init

init() {
    shift                               #To escape the first argument(command itself) and use the rest as address(beacuse address can contain spaces)
    remote_directory=$(echo "$@" | sed "s|/$||" )       #removing any ending backslashes
    if [ ! -d "$remote_directory" ];then
        mkdir -pv "$remote_directory"             #Creates the remote directory along with parent directories if not present
    fi

    if [ -f .git2_remote_dir_path ];then
        present_path="$(cat .git2_remote_dir_path)"
        if [[ "$remote_directory" == "$present_path" ]];then
                echo "$remote_directory already initialised as the git2 repository!!"
                exit 1
        fi
    fi
    
    echo "Initialising $remote_directory as the git2 repository"
   
    touch "$remote_directory/.git2_log"
    #creating a file to store config data
    if [ ! -f "$remote_directory/.git2_config_data" ];then
        touch "$remote_directory/.git2_config_data"
        echo "Name: <Not set>" > "$remote_directory/.git2_config_data"
        echo "Email: <Not set>" >> "$remote_directory/.git2_config_data"
        # echo "--------------------" >> $remote_
        # echo "Use git2_config user.name <Name> and user.email <Email> to configure." >> $remote_dir/.git2_config_data
    fi
    mkdir -p "$remote_directory/branch/master/commits"      #Branching feature is not there, only the master branch
    mkdir -p "$remote_directory/tmp/original"
    echo "$remote_directory" > .git2_remote_dir_path                 #Creating a hidden file to store path of the remote directory

}

#printing the git2 log
log() {
    remote_dir=$(cat .git2_remote_dir_path)
    awk 'BEGIN{FS=",";OFS="\n"} {                     
        printf "\033[1mCommit ID\033[0m: \033[33m%s\033[0m \n", $1           #the escape characters are for setting colours and making text bold.
        print "\033[1mTime\033[0m: " $2
        print "\033[1mAuthor\033[0m: " $3
        OFS=","
        #Since message can contain commas,\" has been added as first character during commit to identify complete message ...so substr removes it
        $1=""
        $2=""
        $3=""
        a=substr($0,5)
        print a
        printf "\n"
        OFS="\n"
    }' "$remote_dir/.git2_log"

}



#Set user name and user email/ view the config data
config() {
    remote_dir=$(cat .git2_remote_dir_path)
    if [[ $1 == "view" ]];then
        cat "$remote_dir/.git2_config_data"
        exit 0
    fi
    if [[ $1 == "user.name" ]];then
        sed -i "1 s|\(Name: \).*|\1$2|" "$remote_dir/.git2_config_data"
        #  echo "Name: $2" > $remote_dir/.git2_config_data
         exit 0
    fi

    if [[ $1 == "user.email" ]];then
        sed -i "1 s|\(Email: \).*|\1$2|" "$remote_dir/.git2_config_data"
        exit 0
    fi    

}



commit() {
    
    if [ ! -f .git2_remote_dir_path ]; then
        echo "Error: Remote directory not initialized. Please run 'git2 init' first."        #Checking if git2 initialised
        exit 1
    fi

    remote_directory=$(cat .git2_remote_dir_path)

    commit_message="$1"
    time=$(date "+%B %d  %H:%M:%S %Y %z")      #Storing time of commit
    commit_id=$(openssl rand -hex 8)            #generating 16-digit random hash value in hex format

    # present_branch=$(cat "$remote_directory/branch/.git2_present_branch")
    mkdir "$remote_directory/branch/master/commits/$commit_id"

    #iterating over all csv files to either save differences or file itself(if its a new file)
    for file in *.csv;do
        if [ -f "$remote_directory/tmp/original/$file" ];then
            diff -u "$remote_directory/tmp/original/$file" "$file" > "$remote_directory/branch/master/commits/$commit_id/$file.patch"
        else
            cp ./"$file" "$remote_directory/tmp/original"
            diff -u "$remote_directory/tmp/original/$file" "$file" > "$remote_directory/branch/master/commits/$commit_id/$file.patch"
        fi
    done


    author=$(awk 'BEGIN{FS=": "} /^Name:/ {                         #setting the author data using configuration file
                    printf "Name-%s ",$2
                }
                /^Email:/ {
                    printf "Email-%s",$2
                }
                    ' "$remote_directory/.git2_config_data")
    
    echo "$commit_id,$time,$author,\"$commit_message" >> "$remote_directory/.git2_log"   #log file of commits

    echo -e "Commit ID: \033[33m$commit_id\033[0m "
    echo "Time: $time"
    echo "Author: $author"
    echo "$commit_message"
    echo "------------------------------------------------------------------------"
    #printing modified files in last commit

    no_of_commits=$(($(wc -l "$remote_directory/.git2_log" | cut -d' ' -f1 )))
    
    if [[ no_of_commits -ge 2 ]];then
        latest_commit=$commit_id
        prev_commit=$(ls -t "$remote_directory/branch/master/commits" | head -n 2 | tail -n 1 )


        mkdir "$remote_directory/tmp/$latest_commit"
        mkdir "$remote_directory/tmp/$prev_commit"

        #Building the latest commit
        for file in "$remote_directory/branch/master/commits/$latest_commit"/*.csv.patch;do
            patch_filename=$(basename "$file")
            csv_filename=$(basename "$file" .patch)
            patch -o "$remote_directory/tmp/$latest_commit/$csv_filename" < "$file" "$remote_directory/tmp/original/$csv_filename" > .patch_tmp     #To suppress the output of patch
        done
        
        #Building the previous to latest commit
        for file in "$remote_directory/branch/master/commits/$prev_commit"/*.csv.patch;do
            patch_filename=$(basename "$file")
            csv_filename=$(basename "$file" .patch)
            patch -o "$remote_directory/tmp/$prev_commit/$csv_filename" < "$file" "$remote_directory/tmp/original/$csv_filename" > .patch_tmp
        done

        #Showing diff in brief
        echo "Modifications in latest commit compared to previous commit:"
        diff -rq "$remote_directory/tmp/$latest_commit" "$remote_directory/tmp/$prev_commit" | sed -E "s|$remote_directory/tmp/$latest_commit|latest_commit|;s|$remote_directory/tmp/$prev_commit|prev_commit|"

        #Removing tmp folders/files
        rm .patch_tmp
        rm -rf  "$remote_directory/tmp/$latest_commit"
        rm -rf "$remote_directory/tmp/$prev_commit"
    else
        echo "This is the first commit only. No modifications to show."
    fi

}


checkout() {
    if [[ $1 == "hash" ]];then
    hash_value="$2"

        remote_directory=$(cat .git2_remote_dir_path)
        # cat $remote_dir/.git2_log
        list_of_commits_log=$(grep -E "^$hash_value.*" "$remote_directory/.git2_log")
        no_of_commits=$(grep -cE "^$hash_value.*" "$remote_directory/.git2_log")       #-c counts number of matching lines
      
        #Case handling for number of matches found for given hash value
        if [ $no_of_commits -eq 0 ];then
            echo "ERROR: No matches found for given hash value"
            exit 1
        elif  [ $no_of_commits -ge 2 ];then
            echo "Multiple matches!!!"
            echo "Matching commits are:"
            echo "$list_of_commits_log"
            read -p "Please re-enter the complete hash value from the above list to checkout (Enter 0 to quit) : " response
            if [[ $response = "0" ]];then
                echo "Checkout cancelled!!"
                exit 1
            else
                checkout "hash" $response
            fi
        else
            #Change-tracking feature to prevent loss of data
            #First checking if any changes in current repository since last commit has not been committed before checking out to other commit
            prev_commit=$(ls -t "$remote_directory/branch/master/commits" | head -n 1 )

            mkdir "$remote_directory/tmp/$prev_commit"
            #Building the previous commit
            for file in "$remote_directory/branch/master/commits/$prev_commit"/*.csv.patch;do
                patch_filename=$(basename "$file")
                csv_filename=$(basename "$file" .patch)
                patch -o "$remote_directory/tmp/$prev_commit/$csv_filename" < "$file" "$remote_directory/tmp/original/$csv_filename" > .patch_tmp
            done

            mkdir .modification_check
            cp ./*.csv ./.modification_check
            changes=$(diff -rq ./.modification_check "$remote_directory/tmp/$prev_commit")
            rm -rf "$remote_directory/tmp/$prev_commit"         #removing tmp files after comparison
            rm -rf .modification_check
            rm .patch_tmp
            if [[ ! $changes = "" ]];then
                echo "Uncommitted changes in current repository found since last commit!!"
                echo "Please run git2 commit first then git2 checkout to save the changes otherwise they will be lost"
                read -p "Enter 0 to quit or 1 to continue without commit : " response
                if [[ $response = "0" ]];then
                    echo "Checkout cancelled!!"
                    exit 1
                fi
            fi
            commit_id=$(echo $list_of_commits_log | cut -d',' -f1)

            #removing current csv files
            rm -f *.csv         # -f to ignore non existent files

            #Building back all csv files from that commit into current repository
            for file in "$remote_directory/branch/master/commits/$commit_id"/*.csv.patch;do
                patch_filename=$(basename "$file")
                csv_filename=$(basename "$file" .patch)
                patch -o "./$csv_filename" < "$file" "$remote_directory/tmp/original/$csv_filename" > .patch_tmp
            done
            rm .patch_tmp
            echo "Current repository successfully checked out to commit_id $commit_id"

        fi
    fi
   
}




#------------------------Running commands------------------------

command=$1

if [[ $command = "init" ]];then
    init $@
    exit 0
fi


if [[ $command = "log" ]];then
    log
    exit 0
fi

if [[ $command = "config" ]];then
    if [ $# -eq 2 ];then
        if [[ $2 == "view" ]];then
            config "$2"
        else
            echo "Usage: bash submission.sh git2 config view/user.name "Name"/user.email "Email""
        fi
    elif [ $# -eq 3 ];then
        if [[ $2 == "user.name" || $2 == "user.email" ]];then
            config "$2" "$3"
        else
            echo "Usage: bash submission.sh git2 config view/user.name "Name"/user.email "Email""
        fi
    else
        echo "Usage: bash submission.sh git2 config view/user.name \"Name\"/user.email \"Email\""
    fi

    exit 0
fi


if [[ $command = "commit" ]];then
    if [[ $# -ne 3 || $2 != "-m" ]];then        #Error handling of commit usage
        echo 'Invalid input...Usage: bash submission.sh git2 commit -m "commit_message"'
        exit 1
    fi
    # echo "$3"
    commit "$3"
    exit 0
fi

if [[ $command = "checkout" ]];then
    if [ $# -eq 2 ];then                        #Checkout by hash value
        checkout "hash" "$2"
        exit 0
    fi
    if [ $# -eq 3 ];then                        #Checkout by message
        if [[ $2 != "-m" ]];then
            echo 'Invalid command....Usage: bash submission.sh -m "commit_message" or checkout <hash value(atleast 1 character)>'
            exit 1
        else
            checkout "message" "$3"
            exit 0
        fi
    fi
fi
