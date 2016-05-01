function[] = loadSrcImg()

// Load source image for the Main Window's source viewport

    // GUI-related variables
    global viewportSrcImg;
    global listboxSrcImg;
    global srcImg;

    // Load the pixel data from the filename specified by the
    // listbox containing source image filenames.
    srcImg = loadpgm(listboxSrcImg.string(listboxSrcImg.value));

    // The loadpgm returns vector, so we have to resize it into
    // 112 rows x 92 columns matrix.
    srcImg = matrix(srcImg,92,112);

    // Draw the source image to the source viewport.
    sca(viewportSrcImg);
    Matplot1(srcImg', [0,0,1,1]);

endfunction
