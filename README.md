# Bash Grader

## 1. Objective
A CSV file manager and interpreter has been created in this project through shell scripting in the form of `submission.sh`. Extra functionalities have been added using Python and its libraries.

## 2. Introduction to Bash Grader
Bash Grader is a bash shell script with two main functionalities: handling a collection of CSV (comma-separated values) files containing students’ data for different exams, and maintaining a GIT-like version control system (in a simpler form) for the CSV files.

## 3. Applications
- **Academics Grading Automation:** Efficiently assembles the data of different exams of the students and produces total marks, making it useful in schools and colleges.
- **CSV Data Management:** The VCS facility helps maintain the integrity of data and track the history of changes made to it, enabling multiple users to work on the same data without conflicts.

## 4. An Overview of the Code
The script `submission.sh` has been written using bash, sed, and awk commands. It combines grading functionalities with basic version control features. It is structured into modular functions, each serving a specific purpose. Comments within the script explain complex operations and enhance code understanding. The code works by taking command line arguments from the user. The script is broadly divided into two parts - Grader and VCS.

### Grader
The Grader part has four main functionalities: Combine, Upload, Total, and Update.

#### Combine
- **Syntax:** `bash submission.sh combine`
- **Working:** Creates a main CSV file that contains the data for all the exams so far, using the data present across all the CSV files in the folder. The function checks if the `main.csv` file already exists and whether it already has a "total" column. It creates a temporary CSV file and initializes it with essential headers (roll number, marks, and exam names extracted from the CSV filenames). The roll number array is updated for each new roll number found, and a corresponding associative array of that roll number is created. After reading all the files, it starts to append the data of each roll number in the roll number array, line by line in the temporary file. Finally, it renames the temporary file to `main.csv` and gives an affirmation message.

#### Upload
- **Syntax:** `bash submission.sh upload "path to the CSV file"`
- **Working:** Takes the path of the CSV file and copies it into the present directory, used when the user wants to import data of a new exam file.

#### Total
- **Syntax:** `bash submission.sh total`
- **Working:** If the `main.csv` file has been already created, this function will create a new column (with heading "total") in `main.csv`, which stores the total of every student (with absent being treated as 0).

#### Update
- **Syntax:** `bash submission.sh update`
- **Working:** Takes the roll number and name of the student (whose marks have to be changed) as input with appropriate prompts to the user. It updates the data in both `main.csv` and the exam’s CSV file using awk, if the roll number and name match is found and if the input format is correct.

### CSV VCS
The purpose of the CSV VCS is to save all the versions of the current folder (of CSV files only) in some other folder. It provides mainly the following three commands:

#### Git Init
- **Syntax:** `bash submission.sh git init "path to remote directory"`
- **Working:** Initializes a directory as a Git repository. It checks if the directory has already been initialized as a Git repository and creates necessary directories and files in the Git repository for Git operation.

#### Git Commit
- **Syntax:** `bash submission.sh git commit -m "commit message"`
- **Working:** Checks if the remote directory has been initialized as a git repository using `git init()`. It provides a change-tracking feature, creating a unique commit ID and saving the current version in the remote folder. It prints the commit ID, time, author, and commit message to the terminal.

#### Git Checkout
- **Syntax:** `bash submission.sh git checkout -m "commit message"`
- **Syntax:** `bash submission.sh git checkout <hash value (at least 1 character)>`
- **Syntax:** `bash submission.sh git checkout`
- **Working:** Checks the argument format to determine whether the checkout should be performed based on a hash value or a commit message. It copies the CSV files from the selected commit’s directory to the current directory, reverting the current directory back to that commit ID.

## 5. Working/Usage of the Code
Open a terminal and change the directory to the one containing the script. Ensure that the CSV files you are going to work with are present in the same directory. The general syntax of giving a command is:
```bash
bash submission.sh <command> <attributes>
```
Following is the usage syntax and working logic of each functionality:

### Grader
#### Combine
- **Syntax:** `bash submission.sh combine`
- **Working:** Combines the data from all CSV files into a main CSV file.

#### Upload
- **Syntax:** `bash submission.sh upload "path to the CSV file"`
- **Working:** Uploads a new CSV file into the directory.

#### Total
- **Syntax:** `bash submission.sh total`
- **Working:** Calculates the total marks for each student and adds a new column to the `main.csv`.

#### Update
- **Syntax:** `bash submission.sh update`
- **Working:** Updates the marks of a student in one or more exams.

### CSV VCS
#### Git Init
- **Syntax:** `bash submission.sh git init "path to remote directory"`
- **Working:** Initializes a directory as a Git repository.

#### Git Commit
- **Syntax:** `bash submission.sh git commit -m "commit message"`
- **Working:** Commits changes to the Git repository.

#### Git Checkout
- **Syntax:** `bash submission.sh git checkout -m "commit message"`
- **Syntax:** `bash submission.sh git checkout <hash value (at least 1 character)>`
- **Syntax:** `bash submission.sh git checkout`
- **Working:** Checks out a specific commit based on hash value or commit message.

## 6. Customizations
For using the customizations (6.1.1 and 6.1.2), ensure that `matplotlib`, `numpy`, `pandas`, and `sys` libraries are installed. In the file `submission.sh`, there are various customizations included (mainly through auxiliary files) which are as follows:

### Grader
#### Exam Report Graph-cum-Statistics
- **Syntax:** `bash submission.sh exam stats`
- **Working:** Allows viewing the report of a single exam or all the exams combined together. The command runs the `Exam stats.py` file which prompts the user to input the exam name or "all" to view statistics for all exams at once.

#### Student’s Data Extraction and Performance Report
- **Syntax:** `bash submission.sh student stats`
- **Working:** Prompts the user for the student’s roll number and checks for it in the main file. It extracts the student’s marks across all exams and displays them to the user. Optionally, it generates a performance report using a Python script.

#### Multi-exam Marks Update
- **Syntax:** `bash submission.sh update`
- **Working:** Allows updating the marks of a student in multiple exams by entering the roll number and name once.

### CSV VCS
#### Git Log
- **Syntax:** `bash submission.sh git log`
- **Working:** Displays the commit ID, author, time of commit, and commit message of each commit done till now.

#### Git Config
- **Syntax:** `bash submission.sh git config <nothing>/ user.name <name> / user.email <email>`
- **Working:** Used to set author configuration. When no argument is given to `git config`, it displays the present configuration.

#### Change Tracker
Tracks changes in the current repo since the last commit, preventing data loss when doing checkout to some commit ID.

#### More Powerful Git (GIT2)
Stores changes in the current repository in a commit ID instead of copying the whole current repository, making it memory efficient and more powerful. Uses the commands `diff` and `patch`.

#### Error Handling for Maintaining Correct Git Usage
Prompts the user with the correct usage format if the user enters the wrong format of git commands.

## References
1. [Dynamic Construction through `eval` command](https://tldp.org/LDP/abs/html/arrays.html)
2. [OpenSSL Rand](https://www.openssl.org/docs/man1.1.1/man1/rand.html)
3. [Matplotlib](https://matplotlib.org/)
4. [Diff and Patch](https://www.gnu.org/software/diffutils/manual/diffutils.html)
