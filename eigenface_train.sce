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
    global numOfEigenfaces;
    global facevector;
    global imagesPerPerson;
    global wTrainingSet;


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
    // STEP 5: Find covariance matrix (Matrix L).
    // Matrix L is a covariance matrix, but we use a different
    // technique to find the covariance. This technique is described
    // in TurkPentland1991a paper:
    // http://www.ece.lsu.edu/gunturk/EE7700/Eigenface.pdf
    //////////////////////////////////////////////////////////////////

    L = meansubtvector' * meansubtvector;


    //////////////////////////////////////////////////////////////////
    // STEP 6: Find eigenvalue and eigenvector of the matrix L.
    // Using Scilab's spectral decomposition method to find
    // eigenvalue and eigenvector.
    //////////////////////////////////////////////////////////////////

    [eigenvector_L, eigenvalues_L] = spec(L);

    // Sort eigenvalues and eigenvector in descending order
    [s,k] = gsort(diag(eigenvalues_L))
    eigenvalues_L = eigenvalues_L(k,k)
    eigenvector_L = eigenvector_L(:,k)

    // Normalize the eigenvector
    [rows, cols] = size(eigenvector_L)
    for i=1:1:cols
        maxVal = max(abs(eigenvector_L(:,i)))
        eigenvector_L(:,i) = eigenvector_L(:,i) / maxVal
    end


    //////////////////////////////////////////////////////////////////
    // STEP 7: Find eigenface.
    // The eigenface is actually the eigenvector of the covariance
    // matrix with "Original Dimensionality". However, the matrix L
    // is a covariance matrix with "Reduced Dimensionality". To find
    // the eigenvector of a covariance matrix with
    // "Original Dimensionality", we have to multiply the eigenvector
    // of matrix L with the matrix meansubtvector.
    //////////////////////////////////////////////////////////////////

    eigenface = zeros(92*112,numOfFaces)
    for i=1:1:numOfFaces
        for j=1:1:numOfFaces
            eigenface(:,i) = eigenface(:,i) + ...
                (eigenvector_L(i,j) * meansubtvector(:,j))
        end
        filename = msprintf("debug/eigen_%d.pgm",i);
        savepgm(matrix(scale_to_255(eigenface(:,i)),112,92),filename)
    end

    // Find weights for each person in training data set
    numOfEigenfaces = numOfFaces - 3
    for n=1:1:numOfPerson
        k = 1 + ((n-1) * imagesPerPerson)
        for i=1:1:imagesPerPerson
            for j=1:1:numOfEigenfaces
                wTrainingSet(j,i,n) = ...
                    eigenface(:,j)' * (facevector(:,k) - meanvector)
            end
            k = k + 1
        end
    end

endfunction
