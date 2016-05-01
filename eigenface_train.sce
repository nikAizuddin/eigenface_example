function[] = eigenface_train()

//       1         2         3         4         5         6         7
//34567890123456789012345678901234567890123456789012345678901234567890
//////////////////////////////////////////////////////////////////////
//
// Title: Train the Eigenface Recognizer.
//
//--------------------------------------------------------------------
//       Author: Nik Mohamad Aizuddin bin Nik Azmi
// Date Created: 29-MAR-2015
//--------------------------------------------------------------------
//
//////////////////////////////////////////////////////////////////////

    // Graphical User Inteface variables
    global srcImg;
    global listboxSrcImg;

    // These global variables are used by this function and the value
    // can be accessed by other functions.
    global meanvector;
    global numOfPerson;
    global numOfFaces;
    global eigenface;
    global facevector;
    global imagesPerPerson;


    //////////////////////////////////////////////////////////////////
    // STEP 1: Load all images from the ORL Database.
    // First, we have to fill the variable face[] with the
    // images from the database.
    //////////////////////////////////////////////////////////////////

    k = 1; // row index for variable face[] in this loop;
    for i=1:1:numOfPerson
    for j=1:1:imagesPerPerson
        filename  = msprintf("att_faces/orl_faces/s%d/%d.pgm", i, j);
        face(k,:) = loadpgm(filename);
        k = k + 1;
    end
    end


    //////////////////////////////////////////////////////////////////
    // STEP 2: Convert to face vector space.
    // Principle Component Analysis doesn't work directly on images.
    // We have to convert from:
    //   face(numOfFaces, 92*112 pixels) to
    //   face(92*112 pixels, numOfFaces) and stored into facevector
    // variable.
    //////////////////////////////////////////////////////////////////

    facevector = face';


    //////////////////////////////////////////////////////////////////
    // STEP 3: Find mean value from all faces.
    // We must find the common features of human faces, so that when
    // we subtract it with the sample or training faces, we will get
    // the unique feature of the face.
    //////////////////////////////////////////////////////////////////

    [rows, cols] = size(facevector);
    // rows is the number of pixels (92*112 pixels)
    // cols is the number of faces

    // For each pixel, find the mean of a pixel from all faces.
    for r=1:1:rows
        total = 0;
        for c=1:1:cols
            total = total + facevector(r,c);
        end
        meanvector(r) = total / cols;
    end

    // meanvector is a row vector with size 92*112.


    //////////////////////////////////////////////////////////////////
    // STEP 4: Find the unique features for each training faces.
    // The result, meansubtvector is a matrix, same size as facevector,
    // and this matrix will have 0 mean.
    // Also, the matrix will contains only unique feature of training
    // faces.
    //////////////////////////////////////////////////////////////////

    meansubtvector = facevector - repmat(meanvector,1,cols);


    //////////////////////////////////////////////////////////////////
    // STEP 5: Find covariance matrix.
    // Matrix L is a covariance matrix, but we use a different
    // technique to find the covariance. This technique is described
    // in TurkPentland1991a paper:
    // http://www.ece.lsu.edu/gunturk/EE7700/Eigenface.pdf
    //////////////////////////////////////////////////////////////////

    L = meansubtvector' * meansubtvector;


    //////////////////////////////////////////////////////////////////
    // STEP 6: Find eigenvalue and eigenvector of the matrix L.
    //////////////////////////////////////////////////////////////////

    [eigenvector_L, eigenvalues_L] = spec(L);


    //////////////////////////////////////////////////////////////////
    // STEP 7: Find eigenface.
    // The eigenface is actually the eigenvector of the covariance
    // matrix with "Original Dimensionality". However, the matrix L
    // is a covariance matrix with "Reduced Dimensionality". To find
    // the eigenvector of a covariance matrix with
    // "Original Dimensionality", we have to multiply the eigenvector
    // of matrix L with the matrix meansubtvector.
    //////////////////////////////////////////////////////////////////

    // Allocate Scilab heap memory
    eigenface = zeros(92*112, numOfFaces);

    for i=1:1:numOfFaces
        eigenface(:,i)  = meansubtvector * eigenvector_L(:,i);
    end


    //////////////////////////////////////////////////////////////////
    // STEP 8 (Optional): Scale eigenface to 255 for display purpose.
    // First, we have to normalized the eigenvector so that the
    // range of the vector is within 0.0 -> 1.0.
    // Then, we can scale it to 255 to visualize it.
    //
    // NOTE: During recognizing images, Scaled_eigenface[] variable
    // is not used, it is only used for print to .pgm files only.
    // The variable eigenface[] is used instead, for recognizing.
    //////////////////////////////////////////////////////////////////

    for i=1:1:numOfFaces
        Scaled_eigenface(:,i) = scale_to_255(eigenface(:,i));
    end


    //////////////////////////////////////////////////////////////////
    // The Face database is now prepared. At this point, the system
    // is now ready to recognize the face.
    // However, lets save the result for inspection.
    // These saved files are not used for recognizing.
    //////////////////////////////////////////////////////////////////

    // Save all images from facevector[] variable
    for i=1:1:numOfFaces
        filename = msprintf("debug/facevector_%d.pgm",i);
        savepgm( facevector(:,i), filename);
    end

    // Save all images from meansubtvector[] variable
    for i=1:1:numOfFaces
        filename = msprintf("debug/meansubtvector_%d.pgm",i);
        savepgm( abs(meansubtvector(:,i)), filename);
    end

    // Save all eigenface images.
    for i=1:1:numOfFaces
        filename = msprintf("debug/eigenface_%d.pgm",i);
        savepgm(Scaled_eigenface(:,i), filename);
    end

    // Save the mean faces image.
    savepgm(matrix(meanvector, 112, 92), 'debug/mean.pgm');

endfunction
