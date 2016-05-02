function[] = search_face()

    // GUI-related variables
    global mainWin_handle;
    global srcImg;
    global listboxSrcImg;
    global viewportResImg1;
    global resImgName1;
    global resPercentMatch1;
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
    global closestPerson;

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

    // Update Main Window result image
    resImg1 = ...
        matrix(facevector(:,1+((closestPerson-1)*imagesPerPerson)),92,112)

    // Update Main Window result viewport
    sca(viewportResImg1);
    Matplot1(resImg1', [0,0,1,1]);
    resImgName1.string = ...
        msprintf("Name: att_faces/orl_faces/s%d/1.pgm",closestPerson);

    // Update analysis table

    // Print distance info to the analysis table
    analysis_row0 = [" ", "Item", "Description"];
    for j=1:1:numOfPerson
        for i=1:1:imagesPerPerson
            k = i+(imagesPerPerson*(j-1));
            analysis_data(k,1) = ...
                "Distance: srcFace <--> s"+string(j)+"/"+string(i)+".pgm";
            analysis_data(k,2) = string(mean(d(:,i,j)));
        end
    end

    // Print the index number to the analysis table
    for i=1:1:size(analysis_data,'r')
        analysis_col0(i) = string(i);
    end

    // Update the table
    analysisTable_handle.string = ...
        [analysis_row0; [analysis_col0 analysis_data]];

endfunction
