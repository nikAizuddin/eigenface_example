function[] = eigenface_recognize()

//       1         2         3         4         5         6         7
//34567890123456789012345678901234567890123456789012345678901234567890
//////////////////////////////////////////////////////////////////////
//
// Title: The Eigenface Recognizer.
//
//--------------------------------------------------------------------
//       Author: Nik Mohamad Aizuddin bin Nik Azmi
// Date Created: 29-MAR-2015
//--------------------------------------------------------------------
//
//////////////////////////////////////////////////////////////////////

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
    global d;    d    = zeros(imagesPerPerson,numOfPerson);
    global minD; minD = zeros(numOfPerson);
    global percentMatched;

    // Find weight for target image (source image or sample image)
    targetFilename = listboxSrcImg.string(listboxSrcImg.value);
    targetImg(:,1) = srcImg;
    targetW        = find_weight(eigenface, ...
        targetImg, ...
        meanvector, ...
        numOfFaces);

    // Find weight for the training face
    for i=1:1:numOfPerson
        wClass(:,:,i) = find_weight_class(eigenface, ...
            facevector, ...
            (imagesPerPerson*(i-1))+1, ...
            meanvector, ...
            imagesPerPerson, ...
            numOfFaces);
    end

    // Euclidean distant between target weight and class weight.
    for i=1:1:numOfPerson
    for j=1:1:imagesPerPerson
        d(j,i) = ...
            sqrt( sum( abs( (targetW(:,1)-wClass(:,j,i) ).^2 ) ) );
    end
    end

    // NOTE:
    //     d(1,1) represents euclidean distance between source face
    //            weight and s1/1.pgm training face weight.
    //     d(1,2) represents euclidean distance between source face
    //            weight and s1/2.pgm training face weight.
    //     d(8,3) represents euclidean distance between source face
    //            weight and s8/3.pgm training face weight.

    // Find minimum distant of person of 
    for i=1:1:numOfPerson
        minD(i) = min(d(:,i));
    end

    // Find the percentage of matching.
    // The lower the distance, the higher the percentage matched.
    for i=1:1:numOfPerson
        percentMatched(i) = 100 - ( (minD(i)/ mean(d) ) * 100 );
    end

endfunction
