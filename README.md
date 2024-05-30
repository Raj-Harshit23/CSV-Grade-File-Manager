1 OBJECTIVE
A csv file manager and interpreter has been created in this project through shell scripting in
the form of submission.sh. Extra functionalities have been added using using Python and its
libraries.

2 INTRODUCTION TO BASH GRADER
Bash grader is a bash shell script with two main functionalities. One is to handle a collection of
CSV(comma separated values) files containing students’ data for different exams. The other is
maintaining a GIT-like version control system (in a simpler form) for the CSV files.

3 APPLICATIONS
Following are a few uses of the Bash Grader:
• Academics Grading Automation: It efficiently assembles the data of different exams of
the students and produces total marks. Hence, it is of great use in schools and colleges.
• CSV Data management: The VCS facility helps maintain the integrity of data and track
the history of changes made to it. It enables multiple users to work on the same data without
any conflicts.

4 AN OVERVIEW OF THE CODE
The script submission.sh has been written using bash, sed and awk commands. It combines
grading functionalities with basic version control features. It is structured into modular functions,
each serving a specific purpose. Comments within the script explain complex operations and enhance
code understanding. The code works by taking command line arguments from the user.
The script is broadly divided into two parts - Grader and VCS.
The first part has four main functionalities: Combine, Upload, Total and Update. As the name
suggests, the purpose of Combine is to create a main CSV file that contains the data for all the
exams so far, using the data present across all the CSV files in the folder. Upload is for importing
a new CSV file into the directory. The total function finds the total marks of each student in
the main file and stores it in a new column. Finally, Update is used to change the marks of a
student in one or more exams by editing the relevant files. Also, there is an essential subpart
which controls the calling of these functions.
The second part consists of the basic features of Git, like git init, git commit, git checkout and
a few others. These all have been implemented using again bash, sed and awk. It is specifically
designed to manage CSV files. Again, a specific part of the script is devoted to running these
commands as required by the user and handling errors in its usage.

5 WORKING/USAGE OF THE CODE
The usage of the script is simple. Open a terminal on your computer and change the directory to
the one containing the script. Ensure that the CSV files you are going to work with are present
in the same directory. The general syntax of giving a command is:
bash submission.sh <command> <attributes>
Following is the usage syntax and working logic of each functionality:
5.1 GRADER
  • COMBINE:
  SYNTAX: bash submission.sh combine
  WORKING:
  First of all, it creates a list of all csv files present in the folder using awk. The function checks if
  the main.csv file already exists and whether it already has a ”total” column (so as to do the total
  again at last). It creates a temporary CSV file and initializes it with essential headers(roll number,
  marks and exam names extracted from the CSV filenames).
  Now, it creates a roll number array. Then it starts to iterate over all the csv files (except
  the main.csv file itself) line by line. Each exam file has only three columns: Roll number,
  Name and marks. The roll number array is updated for each new roll number found, and a
  corresponding associative array of that roll number is created. The associative array saves the
  Name-”name” and examname-”marks” as key-value pairs. The name of this array is uniquely
  created for each roll number using dynamic construction through the ”eval” command (Refer to [1]).
  After reading all the files, it starts to append the data of each roll number in the roll number
  array, line by line in the temporary file. For this purpose, it first reads the corresponding
  header(exam name) in the temp file and finds the key-value pair of that in the roll number’s
  associative array. It appends the marks accordingly and if the exam is not found, the roll number
  is marked as absent (’a’).
  Finally, it renames the temporary file to ”main.csv” and gives an affirmation message.
  NOTE:
  It can be run every time new csv files are added to update main.csv. It works for any roll number
  format.
  
  • UPLOAD:
  SYNTAX:
  bash submission.sh upload "path to the CSV file"
  WORKING:
  As the syntax suggests, it takes the path of the csv file and copies it into the present directory.
  Hence it can be used when the user wants to import data of a new exam file.
  
  • TOTAL:
  SYNTAX:
  bash submission.sh total
  WORKING:
  If the main.csv file has been already created, this function will create a new column (with heading
  “total”) in main.csv, which stores the total of every student (with absent being treated as 0. It does
  so through an awk file, which reads the main file line by line and sums up the marks in different
  exams for each student.
  
  • UPDATE:
  SYNTAX:
  bash submission.sh update
  WORKING:
  It takes the roll number and name of the student(whose marks has to be changed) as input with
  appropriate prompts to the user. Then the user is displayed a list of exams present in the directory,
  with a prompt to enter the exam(s) for which marks have to be changed. Then the user is required
  to give input in the format - examname1 new marks examname2 new marks and so on(Multiple
  exams’ marks can be changed at the same time).
  Then the function updates the data in both main.csv and exam’s csv file using awk, if the
  roll number and name match is found and if the input format is correct. Else it gives an
  appropriate error message.
  NOTE:
  If the concerned exam file is present in the folder but not combined in main.csv, then the data is
  not updated anywhere.

5.2 CSV VCS
  Its purpose is to save all the versions of our current folder (of csv files only) in some other folder.
  It provides mainly the following three commands:
  • GIT INIT:
  SYNTAX:
  bash submission.sh git init "path to remote directory"
  WORKING:
  This function initializes a directory as a Git repository. It takes the directory path as input.
  It first checks if the directory exists, and if not, it creates all the non-existing required parent
  directories and the Git directory itself as mentioned in the path. Then, it checks if the
  directory has already been initialized as a Git repository by checking for the presence of a
  .git remote dir path file and the path saved in it. If it has been initialized, it exits with an error
  message. Otherwise, it creates necessary directories and files in the Git repository for Git operation.
  
  • GIT COMMIT:
  SYNTAX:
  bash submission.sh git commit -m "commit message"
  WORKING:
  The function starts by checking if the file .git remote dir path exists, which indicates whether
  the remote directory has been initialized as a git repository using git init(). If the file doesn’t
  exist, it prints an error message and exits.
  It reads the path of the remote directory from the .git remote dir path file.
  It provides a change-tracking feature as follows:It determines the number of commits made
  so far. If there have been previous commits, it checks for changes in the current directory
  compared to the last commit. If there are no differences, it prints ”No changes to commit”
  and exits.
  Otherwise, If there are changes to commit or it’s the first commit, it proceeds to create
  a new commit. It generates a unique commit ID of 16 digits in hexadecimal format using
  ”openssl rand” feature (Refer to [2]). It then creates a directory in the remote folder with
  the commit ID and copies all CSV files from the current directory into it. Hence, the current
  version has been saved.
  It retrieves the author’s name and email from the git config data file and appends the
  commit details (ID, time, author, message) to the .git log file.It prints the commit ID, time,
  author, and commit message to the terminal.
  It then prints the modifications between the latest and previous commit. (If it is not the
  first commit).
  
  • GIT CHECKOUT:
  SYNTAX:
  bash submission.sh git checkout -m "commit message"
  bash submission.sh git checkout <hash value(atleast 1 character)>
  bash submission.sh git checkout
  WORKING:
  The function checks the argument format (as shown in syntax) to determine whether the checkout
  should be performed based on a hash value or a commit message.
  For checkout by hash value, it searches for the given initials of the hash value in the .git log file to
  find the corresponding commit. If multiple matches are found, it prompts the user to select one
  and shows error message if no match is found.
  Finally, it copies the CSV files from the selected commit’s directory to the current directory (and
  deletes the CSV files already present in the current directory)and hence, it reverts our current
  directory back to that commit id.
  NOTE: As in git commit, there is a change-tracking feature here also to prevent loss of
  data. Before checkout, it checks for uncommitted changes in the current directory since the last
  commit and asks the user whether to proceed without committing those changes(as otherwise,
  those changes will be lost).
  There is an extra feature which allows you to go the latest commit when you give no argument to
  git checkout.
  For running all of these commands properly according to command line arguments, a part of
  the code handles different scenarios, such as incorrect command usage and varying numbers of
  arguments for different commands.
  
6 CUSTOMIZATIONS
For using the customizations(6.1.1 and 6.1.2), ensure that matplotlib, numpy, pandas and sys
libraries are installed. In the file submission.sh, there are various customizations included (mainly
thorugh auxillary files) which are as follows:
Syntax:
6.1 GRADER
  1. Exam Report Graph-cum-Statistics:
  Syntax: bash submission.sh exam stats
  It allows to view the report of a single exam at once or all the exams combined together.The
  command runs the Exam stats.py file which prompts the user to input the exam name or
  ”all” to view statistics for all exams at once.
  • It reads the data from main.csv file using python library Pandas. If the user inputs
  ”all”, the script creates a subplot(histogram of marks vs number of students) for each
  exam using Matplotlib(Refer to [3]).
  • If the user inputs the name of a specific exam, the script plots statistics for that
  exam only.Additionally, it adds a vertical line representing the mean of the marks,
  and displays statistical values such as mean, count, min, max, and quartiles as text on
  the plot.
  2. Student’s Data extraction and Perofrmance Report:
  Syntax: bash submission.sh student stats
  • Data Extraction:When the script is run, it prompts the user for the student’s roll
  number and checks for it in the main file. If the roll number is found, it extracts the
  student’s marks across all exams and displays it to the user.
  • Performance Report Generator:After extracting the data, the script asks if the
  user wants to see the performance report of the student across all the exams. Depending
  upon the response, the script runs a python script student stats.py. It generates
  a plot(subplots of bar charts) which provides a concise and visually appealing performance
  report for that student, comparing their marks with the class’s highest and mean
  marks across all exams.
  3. Multi-exam marks update:
  Syntax: bash submission.sh update
  The marks of a student in multiple exams can be updated, just by entering the roll number
  and name once. Its usage is already discussed in section 5.1.

6.2 CSV VCS
  1. GIT LOG:
  Syntax: bash submission.sh git log
  Similar to the original git log, it displays the commit id, author, time of commit and commit
  message of each commit done till now.

  3. GIT CONFIG:
  Syntax: bash submission.sh git config <nothing>/ user.name <name> / user.email
  <email>
  Again like original git, it is used to set author configuration. When no argument is given to
  git config, it simply displays the present configuration.

  4. CHANGE TRACKER:
  As discussed in the usage of git commit and git checkout earlier, this feature tracks the
  changes in the current repo since last commit. It has two uses: preventing the loss of data
  when doing checkout to some commit id . It checks for uncommitted changes in the current
  directory since the last commit and asks the user whether to proceed without committing
  those changes(as otherwise, those changes will be lost). While the other use is to prevent
  unnecessary commits when there is no change since last commit.

  5. More powerful Git (GIT2): The git2 works by storing changes in the current repository
  in a commit ID instead of copying the whole current repository, which is how the git discussed
  in 5.2 works. Hence it is memory efficient and more powerful. It does so by making use of
  the commands ”diff” and ”patch” (Refer to [4]). The commands available for git2 is same
  as that for the git discussed earlier. The only difference in syntax is as follows:
  bash submission.sh git2 <command> <attributes>
  in place of
  bash submission.sh git <command> <attributes>
  
  6. Error handling for maintaining correct git usage:
  If the user enters wrong format of git commands by chance, error handling has been done
  to prompt the user with the correct usage format.
