================================================================================
README — MATLAB Code for: [Reversible Data Hiding-Based Contrast Enhancement Using
Histogram Redistribution and Gated Skip U-Net(GS-U-Net)]

================================================================================

OVERVIEW
--------
This package contains the MATLAB scripts and functions used to produce the
experimental results reported in the paper. The code covers [contrast enhancement of medical images, e.g. image preprocessing, ROI image histogram modification, and result visualization].


--------------------------------------------------------------------------------
REQUIREMENTS
--------------------------------------------------------------------------------

  - MATLAB version  : R2019b or later 
  - Required Toolboxes:
      * Image Processing Toolbox
  - Operating System : Windows / Linux / macOS (any)
  - RAM              : Minimum 8 GB recommended
  - GPU (optional)   : CUDA-compatible GPU for faster processing


--------------------------------------------------------------------------------
FOLDER STRUCTURE
--------------------------------------------------------------------------------

 
  |-- README.txt               <- This file
  |-- Isaac_new.m                   
  |-- Input grayscale image from file/
  |   |-- [Load ROI of image from file]
  |-- functions/
  |   |-- Isaac_Histogram.m            <- [to generate histogram of the ROI image]
  |   |-- IsaacSplitHistogram.m        <- [for splitting and redistribution in ROI histogram]
  |   |-- Isaac_findpeakbin.m            <- [determine peak bin for histogram stretching]
      |--  Isaac_GrayStretch.m          <- [performs an iterative loop for ROI stretching]
  |   |-- Isaac_NewFindPeakbin.m         <- [perform data embedding into ROI]
      |-- NROIHisto=Isaac_Histogram(ROIEmbeded,ROI,2);      <- [LSB embedding into NROI]
     


--------------------------------------------------------------------------------
DATA
--------------------------------------------------------------------------------

The experiments use the following dataset(s):
    - [Dataset name] — available at: [https://www.kaggle.com/lordamoah/datasets, .https://www.kaggle.com/datasets/
mohammadhossein77/data/normal]
    - Place downloaded data in the data/ folder before running the code.

  NOTE: For model training/evaluation [Majority of the functions used in the codes, especially trained models can be found in 	https://drive.google.com/drive/folders/1NGSfKDM2VXYg99z-U4dF05PvjJpoclWm?usp=drive_link  , due to space constraint.]


--------------------------------------------------------------------------------
HOW TO RUN
--------------------------------------------------------------------------------

  Step 1 — Open MATLAB and set the working directory to the root folder:
             >> cd('/path/to/code/root')

  Step 2 — Add all subfolders to the MATLAB path:
             >> addpath(genpath('.'))

  Step 3 — [If applicable] Configure parameters in Isaac_new.m:
             Open Isaac_new.m and set the following variables at the top of the file:
               - dataPath   : path to input data
               - outputPath : path where results will be saved
               

  Step 4 — Run the main script:
             >> Isaac_new.m

  Step 5 — View results:
             Output figures and tables will be saved to the results/ folder.
             Key outputs include:
               - [e.g., Histogram of original image, splitted and redistributed image, stretched and embedded image]
               - [PSNR/SSIM/RCE and ROI embedding metrics will be displayed in the terminal]

 


--------------------------------------------------------------------------------
EXPECTED RUNTIME
--------------------------------------------------------------------------------

  Full pipeline  : approximately 2 minutes on a standard CPU



================================================================================