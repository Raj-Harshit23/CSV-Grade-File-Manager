import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import math
import sys

df = pd.read_csv("main.csv")        

df.iloc[:, 2:] = df.iloc[:, 2:].apply(pd.to_numeric, errors='coerce').fillna(0)     #To set all non-existing values or 'a' as 0

#To compare roll numbers, both of them are converted to lower so that matching is case insensitive
roll_number = sys.argv[1].lower()           
student_data = df[df['Roll_Number'].str.lower() == roll_number]     #Extract the row of student's data
student_name = student_data['Name'].iloc[0]

exam_columns = df.columns[2:]       #Since first two columns are roll number and name

#Setting the display configurations
no_of_exams = len(exam_columns)
length_of_plot=math.ceil((no_of_exams)/2)

fig, axs = plt.subplots(2,length_of_plot, figsize=(11, 7))
fig.suptitle(f"Performance Report of {student_name} ({roll_number})")   #Overall title of subplots

for i, exam in enumerate(exam_columns):     #Creating a bar chart for each exam
    exam_data = student_data[exam].astype(float)      #   Maintaining float datatype
    highest = df[exam].astype(float).max()
    mean = df[exam].astype(float).mean()

    plt.subplot(2,length_of_plot,i+1)
    plt.bar(['Highest', 'Student', 'Mean'], [highest, exam_data.values[0], mean], color=['blue', 'yellow', 'red'])
    plt.title(f"{exam.capitalize()}")
    plt.ylabel('Marks')

plt.tight_layout()
plt.show()
