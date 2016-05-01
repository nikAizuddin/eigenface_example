function[] = search_face()

    // GUI-related variables
    global mainWin_handle;
    global srcImg;
    global listboxSrcImg;
    global viewportResImg1;
    global viewportResImg2;
    global viewportResImg3;
    global viewportResImg4;
    global resImgName1;
    global resImgName2;
    global resImgName3;
    global resImgName4;
    global resPercentMatch1;
    global resPercentMatch2;
    global resPercentMatch3;
    global resPercentMatch4;
    global is_eigenface_trained;
    global progState;
    global analysis_row0;
    global analysis_col0;
    global analysis_data;
    global analysisTable_handle;

    global meanvector;
    global numOfPerson;
    global numOfFaces;
    global eigenface;
    global facevector;
    global imagesPerPerson;
    global d;
    global minD;
    global percentMatched;

    // We only train eigenface for the first time the program run.
    if is_eigenface_trained == "false"
        progState.string = "Training eigenface. Please wait...";
        progState.backgroundColor = [0.5 0.3 0.3];

        eigenface_train();
        is_eigenface_trained = "true";

        progState.string = "Training eigenface done!";
        progState.backgroundColor = [0.3 0.5 0.3];
    end

    //////////////////////////////////////////////////////////////////
    // Recognize the face
    //////////////////////////////////////////////////////////////////

    progState.string = "Recognizing. Please wait...";
    progState.backgroundColor = [0.5 0.3 0.3];

    eigenface_recognize();

    progState.string = "Recognizing done!";
    progState.backgroundColor = [0.3 0.5 0.3];


    //////////////////////////////////////////////////////////////////
    // At this point, we have done recognizing image.
    //////////////////////////////////////////////////////////////////


    //////////////////////////////////////////////////////////////////
    // Now, update the result viewports and analysis table as output.
    //////////////////////////////////////////////////////////////////


    // Find the top 4 highest percentage of matching.
    temp = percentMatched;
    [value, index1] = max(temp); // Get Top 1st
    temp(index1) = 0;
    [value, index2] = max(temp); // Get Top 2nd
    temp(index2) = 0;
    [value, index3] = max(temp); // Get Top 3rd
    temp(index3) = 0;
    [value, index4] = max(temp); // Get Top 4th

    // Update Main Window result image 1, 2, 3, and 4.
    resImg1 = ...
        matrix(facevector(:,((index1-1)*imagesPerPerson)+1),92,112);
    resImg2 = ...
        matrix(facevector(:,((index2-1)*imagesPerPerson)+1),92,112);
    resImg3 = ...
        matrix(facevector(:,((index3-1)*imagesPerPerson)+1),92,112);
    resImg4 = ...
        matrix(facevector(:,((index4-1)*imagesPerPerson)+1),92,112);

    // Update Main Window result viewport 1
    sca(viewportResImg1);
    Matplot1(resImg1', [0,0,1,1]);
    resImgName1.string = ...
        msprintf("Name: att_faces/orl_faces/s%d/1.pgm",index1);
    resPercentMatch1.string = ...
        msprintf("Match: %.2f%%",percentMatched(index1));

    // Update Main Window result viewport 2
    sca(viewportResImg2);
    Matplot1(resImg2', [0,0,1,1]);
    resImgName2.string = ...
        msprintf("Name: att_faces/orl_faces/s%d/1.pgm",index2);
    resPercentMatch2.string = ...
        msprintf("Match: %.2f%%",percentMatched(index2));

    // Update Main Window result viewport 3
    sca(viewportResImg3);
    Matplot1(resImg3', [0,0,1,1]);
    resImgName3.string = ...
        msprintf("Name: att_faces/orl_faces/s%d/1.pgm",index3);
    resPercentMatch3.string = ...
        msprintf("Match: %.2f%%",percentMatched(index3));

    // Update Main Window result viewport 4
    sca(viewportResImg4);
    Matplot1(resImg4', [0,0,1,1]);
    resImgName4.string = ...
        msprintf("Name: att_faces/orl_faces/s%d/1.pgm",index4);
    resPercentMatch4.string = ...
        msprintf("Match: %.2f%%",percentMatched(index4));

    // Update analysis table
    // Print distance info to the analysis table
    analysis_row0 = [" ", "Info", "Description"];
    for j=1:1:numOfPerson
        for i=1:1:imagesPerPerson
            k = i+(imagesPerPerson*(j-1));
            analysis_data(k,1) = ...
                "srcFace <--> s"+string(j)+"/"+string(i)+".pgm";
            analysis_data(k,2) = string(d(i,1));
        end
    end

    // Print minimum distance into the analysis table
    j = 1;
    for i=k+1:1:numOfPerson+k
        analysis_data(i,1) = msprintf("Minimum distance with S%d",j);
        analysis_data(i,2) = string(minD(j));
        j = j + 1;
    end
    k = numOfPerson+k;

    // Print the percentage matched to the analysis table
    j = 1;
    for i=k+1:1:numOfPerson+k
        analysis_data(i,1) = "S"+string(j)+" percentage matched";
        analysis_data(i,2) = string(percentMatched(j))+"%";
        j = j + 1;
    end
    k = numOfPerson+k;

    // Print the index number to the analysis table
    for i=1:1:size(analysis_data,'r')
        analysis_col0(i) = string(i);
    end

    // Update the table
    analysisTable_handle.string = ...
        [analysis_row0; [analysis_col0 analysis_data]];

endfunction
