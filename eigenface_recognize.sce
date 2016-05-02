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
    global resImgName1;
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
    global numOfEigenfaces;
    global wTrainingSet;
    global facevector;
    global imagesPerPerson;
    global closestPerson;
    global d

    // Find weight for target image (source image or sample image)
    targetFilename = listboxSrcImg.string(listboxSrcImg.value)
    targetImg(:,1) = srcImg
    for i=1:1:numOfEigenfaces
        wTarget(i) = eigenface(:,i)' * (targetImg(:,1) - meanvector)
    end
    
    // Find Euclidean Distance
    for n=1:1:numOfPerson
        for i=1:1:imagesPerPerson
            for j=1:1:numOfEigenfaces
                d(j,i,n) = sqrt(sum( (wTarget(j) - wTrainingSet(j,i,n))^2 ))
            end
        end
    end

    // Find closest distance
    closest = %inf
    for n=1:1:numOfPerson
        for i=1:1:imagesPerPerson
            if (mean(d(:,i,n)) < closest)
                closest = mean(d(:,i,n))
                closestPerson = n
            end
        end
    end

endfunction
