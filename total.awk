BEGIN{
    FS=","
    OFS=","
    already_total_created=0 
}

{
    #Appending the header "total" if not created
    if(NR==1)
    {
        if($NF!= "total")
        {
            print $0,"total"
        }
        else
        {
            print $0
            already_total_created=1
        }
    }
    else
    {
        #Summing over the columns of exam Marks
        
        total=0
        for(i=3; i<=(NF-already_total_created); i++)
        {
            if( $i != "a")
            {
                total+=$i
            }
        }
        if(already_total_created)
        {
            for(i=1; i<NF; i++)
            {
                printf "%s,", $i
            }
            print total
        }
        else
        {
            print $0,total
        }
    }
}