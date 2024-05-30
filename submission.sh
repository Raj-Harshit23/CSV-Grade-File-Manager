#/!usr/bin/env bash

#####################   GRADER   ###################################


    #Getting the list of exam names from filenames
    exam_file_list=$(ls -l | awk 'BEGIN{             
                        FS=" "
                        OFS=","
                        ORS=","
                    }                    
                    {
                        if($NF!="main.csv" && $NF ~ /.+\.csv$/ )     #Validating the filename
                        {
                            print $NF 
                        } 

                    }')
    file_name_list=$(echo $exam_file_list | sed 's/,$//')
    exam_name_list=$(echo $exam_file_list | sed 's/.csv//g; s/,$//')

    #Creating an array of file names
    oldIFS="$IFS"
    IFS=','
    read -ra file_array <<< "$file_name_list"
    IFS="$oldIFS"

    for file in "${file_array[@]}";do
        sed -i -e '$a\' $file    #To add newline character at the end of the file if not present(so that line reading works for last line)
    done

#combine

combine() {
    do_total_at_last=0
    
    if [ -e "main.csv" ]; then          #Checking if main.csv and total column already exists, so that total function should be called at last.
        if [ $(head -n 1 main.csv | rev | cut -d',' -f1 | rev) = "total" ];then
            do_total_at_last=1
        fi
    fi

    touch temp_student.csv.tmp
    chmod 777 temp_student.csv.tmp #Creating a temporary csv file

    echo -n "Roll_Number,Name," > temp_student.csv.tmp      #Creating two essential headers
    
    echo $exam_name_list >> temp_student.csv.tmp    #Appending the headers to the csv file

    declare -a roll_numbers_list

    #Iterating over all the csv file to store each student's information in individual associative arrays named after their roll numbers
    for file in "${file_array[@]}";do
        
        accepted_file_regex=".+\.csv"               #Validating file name
        if [[ $file != "main.csv" && $file =~ $accepted_file_regex ]]; then
            i=0
            
            file_without_extension="${file%.csv}"
            while read -r line;do
                
                if [[ $i = 0 ]];then
                    ((i++))  
                    continue              #Skipping header line
                fi
                roll_no=$(echo $line | cut -d',' -f1)

                if  $(echo "${roll_numbers_list[@]}" | grep -wiqF "$roll_no") ;then   #Checking if we have already found the same roll number(case-insensitive) before 
                                                                                        #([[]] does not work with $(), -q directly evaluates exit status)
                    marks=$(echo $line | cut -d',' -f3)
                    eval "roll_array_$roll_no[\"\$file_without_extension\"]=\"\$marks\""         
                else
                   
                    roll_numbers_list+=("$roll_no")               #updating the array of roll numbers
                    declare -A "roll_array_$roll_no"                           #creating an associative array for each new roll number to store name and marks
                    name=$(echo $line | cut -d',' -f2)
                    eval "roll_array_$roll_no[\"Name\"]=\"\$name\""      #Setting the key-values
                    marks=$(echo $line | cut -d',' -f3)
                    eval "roll_array_$roll_no[\"\$file_without_extension\"]=\"\$marks\""
                fi
                # }
            done < $file
        fi
    done

        header_csv=$(cut -d',' -f 2- temp_student.csv.tmp)      #extracting headers to fill the corresponding fields of students
        oldIFS="$IFS"
        IFS=','
        read -ra headers_array <<< "$header_csv"
        IFS="$oldIFS"

    for roll_no in "${roll_numbers_list[@]}";do
        
        #Now appending these data in the temp_student.csv.tmp file
        student_data_row="$(echo -n "$roll_no,")"               
        
        declare -n roll_array="roll_array_$roll_no"        #referencing the dynamically constructed array name

        for header in "${headers_array[@]}";do
            if [[ -v roll_array["$header"] ]]; then
                student_data_row+="$(echo -n "${roll_array["$header"]}")," 
            else
                student_data_row+="a," 
            fi
            
        done
        student_data_row=$( echo $student_data_row | sed 's/,$//' )
        echo $student_data_row >> temp_student.csv.tmp
        
    done
    mv "temp_student.csv.tmp" "main.csv"

    if [[ $do_total_at_last = "1" ]];then
        total
    fi
    echo "Combined successfully"
}
# }

#upload

upload() {
    cp "$1" ./   #Copy the file from given path to the present directory
}

#total

total() {
        if [ -e "main.csv" ];then
            awk -f total.awk main.csv > total.csv.tmp
            mv "total.csv.tmp" "main.csv"
            echo "Total calculated successfully"
        else
           echo  "Error: main.csv file not created!!"
           exit 1
        fi
}


#update

update() {
        read -p "Enter student's name: " name
        read -p "Enter student's roll number: " roll

        #Checking if the roll no  and student name is present
        if $(grep -qiE "^$roll," "main.csv") ;then
            if  $(grep -iE "^$roll," "main.csv" | grep -qi ",$name,");then

                echo "List of exams :"
                for exam in "${file_array[@]}";do
                    exam="${exam%.csv}"
                    echo "$exam"
                done
                read -p "Which exam's marks do you wish to change:(Enter in the format:<exam1> <new_marks> <exam2> <new_marks> and so on) " marks_list
                echo $marks_list
                read -p "Confirm? Enter 1 to continue and 0 to quit " confirm
                if [[ $confirm = "1" ]]; then

                    #Creating an array of queries
                    oldIFS="$IFS"
                    IFS=' '
                    read -ra queries <<< "$marks_list"
                    IFS="$oldIFS"

                    for (( i=0;i<${#queries[@]};i=i+2 ));do
                        exam_name="${queries[$i]}"
                        marks="${queries[$i+1]}"
                        exam_file="$exam_name.csv"
                        if [ -e "$exam_file" ];then
                            
                            #Updating main.csv 
                            awk -v roll="$roll" -v name="$name" -v marks="$marks" -v exam="$exam_name" 'BEGIN{FS=",";OFS=",";total_created=0;exam_column=0}
                                                                                                            {
                                                                                                                if( NR==1 )
                                                                                                                {
                                                                                                                    for ( i=1; i<= NF; i++ )
                                                                                                                    {
                                                                                                                        if( $i==exam )
                                                                                                                        {
                                                                                                                            exam_column=i           #Checking if exam column is present
                                                                                                                            break
                                                                                                                        }
                                                                                                                    
                                                                                                                    }
                                                                                                                    if( $NF=="total")
                                                                                                                    {
                                                                                                                        total_created=1         #checking if total column present
                                                                                                                    }
                                                                                                                    print
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    if( tolower($1) == tolower(roll) && i!=0 )
                                                                                                                    {
                                                                                                                        if(total_created){$NF=$NF+marks-$i}         #updating total
                                                                                                                        $i=marks
                                                                                                                        found=1
                                                                                                                    }
                                                                                                                    print
                                                                                                                }
                                                                                                                
                                                                                                            }' main.csv > main.csv.tmp

                            mv "main.csv.tmp" "main.csv"
                            if  $(grep -i "$roll," "$exam_file" | grep -qi ",$name,");then      #Checking if the student is marked as present or absent for that exam
                                #Updating the exam file
                                awk -v roll="$roll" -v marks="$marks" 'BEGIN{FS=",";OFS=",";found=0}
                                                                            {
                                                                                if( NR==1 )
                                                                                {
                                                                                    print
                                                                                }
                                                                                else
                                                                                {
                                                                                    if( tolower($1) == tolower(roll) )
                                                                                    {
                                                                                        $3=marks
                                                                                        found=1
                                                                                    }
                                                                                    print
                                                                                }
                                                                            
                                                                            }' "$exam_file" > "$exam_file.tmp"
                                
                                mv "$exam_file.tmp" "$exam_file" 
                            
                            else            #if earlier marked as absent
                            
                                #Updating the exam file
                                echo "$roll,$name,$marks" >> "$exam_file"
                            fi
                            echo "$exam_file successfully updated!"
                        else
                            echo "$exam_file not found!! Marks could not be updated"
                            exit 1
                        fi    
                    done
                    echo "main.csv successfully updated"
                    
                fi
            else
                echo "Name not matching with roll number"
            fi
        else
            echo "Roll number not found"
        fi
}



#-----------------------------Running the functions------------------------------              
# time {

function=$1

if [[ $function = "combine" ]]; then
    combine
    exit 0
fi

if [[ $function = "upload" ]]; then
    upload $2
    exit 0
fi

if [[ $function = "total" ]]; then
    total 
    exit 0
fi

if [[ $function = "update" ]]; then
    update
    exit 0
fi
# }



#################################  GIT  ##################################


# git_init

git_init() {
    shift                               #To escape the first argument(command itself) and use the rest as address(beacuse address can contain spaces)
    remote_directory=$(echo "$@" | sed "s|/$||" )       #removing any ending backslashes
    if [ ! -d "$remote_directory" ];then
        mkdir -pv "$remote_directory"             #Creates the remote directory along with parent directories if not present
    fi

    if [ -f .git_remote_dir_path ];then
        present_path="$(cat .git_remote_dir_path)"
        if [[ "$remote_directory" == "$present_path" ]];then
                echo "$remote_directory already initialised as the git repository!!"
                exit 1
        fi
    fi
    
    echo "Initialising $remote_directory as the git repository"
    mkdir "$remote_directory/commits"           #Creates a folder for saving commits later on 
    touch "$remote_directory/.git_log"
    #creating a file to store config data
    if [ ! -f "$remote_directory/.git_config_data" ];then
        touch "$remote_directory/.git_config_data"
        echo "Name: <Not set>" > "$remote_directory/.git_config_data"
        echo "Email: <Not set>" >> "$remote_directory/.git_config_data"
    fi
    echo "$remote_directory" > .git_remote_dir_path                 #Creating a hidden file to store path of the remote directory

}

git_commit() {
    if [ ! -f .git_remote_dir_path ]; then
        echo "Error: Remote directory not initialized. Please run 'git_init' first."        #Checking if git initialised
        exit 1
    fi

    remote_dir=$(cat .git_remote_dir_path)
    no_of_commits=$(($(wc -l "$remote_dir/.git_log" | cut -d' ' -f1 )))         #wc -l prints file name also...so cut

    #Checking if anything has changed since last commit
    if [[ no_of_commits -ge 1 ]];then
        prev_commit=$(ls -t "$remote_dir/commits" | head -n 1 )
        mkdir .modification_check
        cp ./*.csv ./.modification_check
        changes=$(diff -rq ./.modification_check "$remote_dir/commits/$prev_commit")
        rm -rf .modification_check
        if [[ $changes = "" ]];then
            echo "No changes to commit"
            exit 0
        fi
    fi
    
    commit_message="$1"
    time=$(date "+%B %d  %H:%M:%S %Y %z")      #Storing time of commit
    commit_id=$(openssl rand -hex 8)            #generating 16-digit random hash value in hex format

    mkdir "$remote_dir/commits/$commit_id"
    cp ./*.csv "$remote_dir/commits/$commit_id"

    author=$(awk 'BEGIN{FS=": "} /^Name:/ {                         #setting the author data using configuration file
                    printf "Name-%s ",$2
                }
                /^Email:/ {
                    printf "Email-%s",$2
                }
                    ' "$remote_dir/.git_config_data")
    
    echo "$commit_id,$time,$author,\"$commit_message" >> "$remote_dir/.git_log"   #log file of commits

    echo -e "Commit ID: \033[33m$commit_id\033[0m"
    echo "Time: $time"
    echo "Author: $author"
    echo "$commit_message"
    echo "------------------------------------------------------------------------"
    #printing modified files in last commit

    no_of_commits=$(($(wc -l "$remote_dir/.git_log" | cut -d' ' -f1 )))
    if [[ no_of_commits -ge 2 ]];then               

        latest_commit=$commit_id
        prev_commit=$(ls -t "$remote_dir/commits" | head -n 2 | tail -n 1 )

        echo "Modifications in latest commit compared to previous commit:"
        diff -rq "$remote_dir/commits/$latest_commit" "$remote_dir/commits/$prev_commit" | sed -E "s|$remote_dir/commits/$latest_commit|latest_commit|;s|$remote_dir/commits/$prev_commit|prev_commit|" #sed removes the address shown in output
    else
        echo "This is the first commit only. No modifications to show."
    fi
}

git_checkout() {
    if [[ $1 == "hash" ]];then
        hash_value="$2"

        remote_dir=$(cat .git_remote_dir_path)
        # cat $remote_dir/.git_log
        list_of_commits_log=$(grep -E "^$hash_value.*" "$remote_dir/.git_log")
        no_of_commits=$(grep -cE "^$hash_value.*" "$remote_dir/.git_log")       #-c counts number of matching lines
      
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
                git_checkout "hash" $response
            fi
        else
            #First checking if any changes in current repository since last commit has not been committed before checking out to other commit
            prev_commit=$(ls -t "$remote_dir/commits" | head -n 1 )
            mkdir .modification_check
            cp ./*.csv ./.modification_check
            changes=$(diff -rq ./.modification_check "$remote_dir/commits/$prev_commit")
            rm -rf .modification_check
            if [[ ! $changes = "" ]];then
                echo "Uncommitted changes in current repository found since last commit!!"
                echo "Please run git_commit first then git_checkout to save the changes otherwise they will be lost"
                read -p "Enter 0 to quit or 1 to continue without commit : " response
                if [[ $response = "0" ]];then
                    echo "Checkout cancelled!!"
                    exit 1
                fi
            fi
            commit_id=$(echo $list_of_commits_log | cut -d',' -f1)

            #getting back all csv files from that commit, replacing current csv files
            rm -f *.csv         # -f to ignore non existent files
            cp $remote_dir/commits/$commit_id/* .       
            echo "Current repository successfully checked out to commit_id $commit_id"
        fi
    elif [[ $1 == "message" ]];then
        message=$2
        remote_dir=$(cat .git_remote_dir_path)
        # cat $remote_dir/.git_log
        list_of_commits_log=$(grep -E ",\"$message$" "$remote_dir/.git_log")
        # echo $list_of_commits_log
        no_of_commits=$(grep -cE ",\"$message$" "$remote_dir/.git_log")       #-c counts number of matching lines//(wc counts newline also!!)
        # echo $no_of_commits

        #Case handling for number of matches found for given hash value
        if [ $no_of_commits -eq 0 ];then
            echo "ERROR: No matches found for given message"
            exit 1
        elif  [ $no_of_commits -ge 2 ];then
            echo "Multiple matches!!!"
            echo "Matching commits are:"
            echo "$list_of_commits_log"
            read -p "Please re-enter the complete hash value corres. to the message from the above list to checkout (Enter 0 to quit) : " response
            if [[ $response = "0" ]];then
                echo "Checkout cancelled!!"
                exit 1
            else
                git_checkout "hash" $response
            fi
        else
            #First checking if any changes in current repository since last commit has not been committed before checking out to other commit
            prev_commit=$(ls -t "$remote_dir/commits" | head -n 1 )
            mkdir .modification_check
            cp ./*.csv ./.modification_check
            changes=$(diff -rq ./.modification_check "$remote_dir/commits/$prev_commit")
            rm -rf .modification_check
            if [[ ! $changes = "" ]];then
                echo "Uncommitted changes in current repository found since last commit!!"
                echo "Please run git_commit first then git_checkout to save the changes otherwise they will be lost"
                read -p "Enter 0 to quit or 1 to continue without commit : " response
                if [[ $response = "0" ]];then
                    echo "Checkout cancelled!!"
                    exit 1
                fi
            fi
            commit_id=$(echo $list_of_commits_log | cut -d',' -f1)

            #getting back all csv files from that commit, replacing current csv files
            rm -f *.csv         # -f to ignore non existent files
            cp $remote_dir/commits/$commit_id/* .       
            echo "Current repository successfully checked out to commit_id $commit_id"
        fi

    ##CUSTOM FEATURE...If no argument is provided to the function checkout, it will take you to the latest commit
    else 
        #First checking if any changes in current repository since last commit has not been committed before checking out to other commit
        remote_dir=$(cat .git_remote_dir_path)
        prev_commit=$(ls -t "$remote_dir/commits" | head -n 1 )
        mkdir .modification_check
        cp ./*.csv ./.modification_check
        changes=$(diff -rq ./.modification_check "$remote_dir/commits/$prev_commit")
        rm -rf .modification_check
        if [[ ! $changes = "" ]];then
            echo "Uncommitted changes in current repository found since last commit!!"
            echo "Please run git_commit first then git_checkout to save the changes otherwise they will be lost"
            read -p "Enter 0 to quit or 1 to continue without commit : " response
            if [[ $response = "0" ]];then
                echo "Checkout cancelled!!"
                exit 1
            fi
        fi

        #getting back all csv files from that commit, replacing current csv files
        rm -f *.csv         # -f to ignore non existent files
        cp $remote_dir/commits/$prev_commit/* .       
        echo "Current repository successfully checked out to latest commit"
    fi


}


#----------------------------GIT XTRA FEATURES--------------------------------

#printing the git log
git_log() {
    remote_dir=$(cat .git_remote_dir_path)
    awk 'BEGIN{FS=",";OFS="\n"} {
        printf "\033[1mCommit ID\033[0m: \033[33m%s\033[0m\n", $1           #the escape characters are for setting colours and making text bold.
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
    }' "$remote_dir/.git_log"

}



git_config() {
    remote_dir=$(cat .git_remote_dir_path)
    if [[ $1 == "view" ]];then
        cat "$remote_dir/.git_config_data"
        exit 0
    fi
    if [[ $1 == "user.name" ]];then
        sed -i "1 s|\(Name: \).*|\1$2|" "$remote_dir/.git_config_data"
        #  echo "Name: $2" > $remote_dir/.git_config_data
         exit 0
    fi

    if [[ $1 == "user.email" ]];then
        sed -i "1 s|\(Email: \).*|\1$2|" "$remote_dir/.git_config_data"
        exit 0
    fi    

}

# git_diff() {

#     remote_dir=$(cat .git_remote_dir_path)
#     if [[ $# == "0" ]];then
#         no_of_commits=$(($(wc -l "$remote_dir/.git_log" | cut -d' ' -f1 )))

#         #Checking if anything has changed since last commit
#         if [[ no_of_commits -ge 1 ]];then
#             prev_commit=$(ls -t "$remote_dir/commits" | head -n 1 )     #sort by time to find latest commit
#             changes=$(diff -u . "$remote_dir/commits/$prev_commit")
#             if [[ $changes = "" ]];then
#                 echo "No changes since last commit"
#                 exit 0
#             else 
#                 echo "$changes"
#                 exit 0
#             fi
#         else
#             echo "No commits done!"
#             exit 0
#         fi
#     fi

# }





#------------------------------Running Commands--------------------------

command=$1

if [[ $command = "git_init" ]];then
    git_init "$@"
    exit 0
fi

if [[ $command = "git_commit" ]];then
    if [[ $# -ne 3 || $2 != "-m" ]];then        #Error handling of commit usage
        echo 'Invalid input...Usage: bash submission.sh git_commit -m "commit_message"'
        exit 1
    fi
    # echo "$3"
    git_commit "$3"
    exit 0
fi

if [[ $command = "git_checkout" ]];then
    if [ $# -eq 2 ];then                        #Checkout by hash value
        git_checkout "hash" "$2"
        exit 0
    fi
    if [ $# -eq 3 ];then                        #Checkout by message
        if [[ $2 != "-m" ]];then
            echo 'Invalid command....Usage: bash submission.sh git_checkout -m "commit_message" or bash submission.sh git_checkout <hash value(atleast 1 character)>'
            exit 1
        fi
        git_checkout "message" "$3"
        exit 0
    fi
    if [ $# -eq 1 ];then                        #Checkout to latest commit
        git_checkout "latest"
        exit 0
    fi
fi

if [[ $command = "git_log" ]];then
    git_log
    exit 0
fi

if [[ $command = "git_config" ]];then
    if [ $# -eq 2 ];then
        if [[ $2 == "view" ]];then
            git_config "$2"
        else
            echo "Usage: bash submission.sh git_config view/user.name "Name"/user.email "Email""
        fi
    elif [ $# -eq 3 ];then
        if [[ $2 == "user.name" || $2 == "user.email" ]];then
            git_config "$2" "$3"
        else
            echo "Usage: bash submission.sh git_config view/user.name "Name"/user.email "Email""
        fi
    else
        echo "Usage: bash submission.sh git_config view/user.name \"Name\"/user.email \"Email\""
    fi

    exit 0
fi


if [[ $command = "git_diff" ]];then
    if [ $# -eq 1 ];then
        git_diff
    fi
    exit 0
fi


#----------------------------------GIT 2.0--------------------------------------------

if [[ $command = "git2" ]];then
    shift       #To skip the argumnet "git2" itself in $@
    ./git2.sh "$@"
fi

#--------------------------------Statistics--------------------------------------------

if [[ $command = "exam_stats" ]];then
    python3 Exam_stats.py
fi

if [[ $command = "student_stats" ]];then
    if [[ ! -f "main.csv" ]];then
        echo "Main.csv not created! Please combine the data first"
        exit 1
    else
        read -p "Enter student's roll no : " roll
        if $(grep -qEi "^$roll," "main.csv") ;then
            head -n 1 "main.csv"
            grep -iE "^$roll," "main.csv"
            echo "---------------------------------------------------------"
            read -p "Do you want to see student's performance report?(Enter 1 to see or 0 to quit)" response
            if [[ $response = "1" ]];then
                python3 student_stats.py $roll
            fi
            exit 0
        else
            echo "Roll number not found"
        fi
    fi
fi
    