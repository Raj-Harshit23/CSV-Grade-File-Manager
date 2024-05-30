import pandas as pd
import matplotlib.pyplot as plt
import math
import numpy as np

exam_name=input("Enter the exam name(as present in the main.csv file) to view its statistics(Enter \"all\" to see statistics of all exams at once) :")
df=pd.read_csv('main.csv')
if exam_name=="all":
    #Setting configurations for plot display
    no_of_exams=df.shape[1]-2
    length_of_plot=math.ceil((no_of_exams)/2)
    colors= ['red', 'blue', 'yellow', 'orange', 'green', 'brown', 'purple']  

    fig, axs = plt.subplots(nrows=2, ncols=length_of_plot, figsize=(10,7)) 

    fig.subplots_adjust(left=0, right=1, bottom=0, top=1, wspace=0, hspace=0)       #Removing outer axis
    i=1
    for column in df.columns[2:]:      #Reading columns of each exam which start from 3rd column
        
        plt.subplot(2,length_of_plot,i)
        exam_name=column
        marks=df[column]
        marks=pd.to_numeric(marks,errors='coerce').fillna(0)              #Validates and converts to numeric data...replacing a with 0
        
        #bin_edges are required to align edges of histogram with xticks.
        n=(max(marks)-min(marks))//8
        if n!=0 :
            bin_edges = np.arange(min(marks), max(marks)+9, n) 
        else :
            bin_edges = np.arange(min(marks), max(marks)+1, 1)

        #Plotting a histogram for the exam
        plt.hist(marks, bins=bin_edges, color=colors[i%7], edgecolor='black')
        plt.xticks(bin_edges)   

        plt.title(exam_name.upper())
        plt.xlabel("Marks")
        plt.ylabel("No. of students")
        plt.grid(True)
        i=i+1
    plt.tight_layout()
    plt.show()
else :
    if exam_name in df.columns[2:]:
        marks=df[exam_name]
        
        marks=pd.to_numeric(marks,errors='coerce').fillna(0)         #Validates and converts to numeric data..Replacing absent value with 0                 

        #Calculating some stats
        # print(marks.describe())
        
         #Plotting a histogram for the exam
        plt.figure(figsize=(11,7))
        #bin_edges are required to align edges of histogram with xticks.
        n=(max(marks)-min(marks))//8
        if n!=0 :
            bin_edges = np.arange(min(marks), max(marks)+9, n) 
        else :
            bin_edges = np.arange(min(marks), max(marks)+1, 1)

        plt.hist(marks, bins=bin_edges, color='skyblue', edgecolor='black')
        plt.xticks(bin_edges)

        plt.axvline(x=marks.mean(), color='red', linestyle='--', label='Mean')
        plt.text(marks.mean(),0.09,"Mean",ha="center")          
        plt.title(exam_name.upper())
        plt.xlabel("Marks")
        plt.ylabel("No. of students")

        plt.subplots_adjust(left=0.15, right=0.55, top=0.9, bottom=0.15)  #Creating space for showing stats
        #Displaying statistical values
        stats=str(marks.describe().round(4))       
        output_stats=stats.splitlines()      #Removing the object type line
        new_stats='\n'.join(output_stats[:-1])
        
        plt.figtext(0.67, 0.5, new_stats, ha="left", va="center", fontsize=12)
        plt.grid(True)

        plt.show()