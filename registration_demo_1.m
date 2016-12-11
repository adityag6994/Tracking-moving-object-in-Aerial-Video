%FCV Term Paper
display('entee he path for dataset2 folder');
%input the path
cd('G:\final folder\data set 2'); 
iat_setup;
iat_setup('FOREVER');
%cd('F:\sem6\fcv\term papaer\data set 2'); 
f_list = dir('*jpg'); %Reading all the images of test case


%% Feature base alignment (Image registration)(Part 1)
ransacMosaic = imread(f_list(1).name); %Reading first image as the base image for mosaicing

for i = 1:5:length(f_list); % Reading every fifth frame from the test case
        i
        img = uint8(ransacMosaic); 
% Reading the next frame to be mosaiced to the previously mosaiced image
        tmp = imread(f_list(i+1).name);
% Extract SURF features and match them
        [d1, l1]=iat_surf(img,128);
        [d2, l2]=iat_surf(tmp,128);
        [map, matches, imgInd, tmpInd]=iat_match_features(d1,d2,.9);
        ptsA=l1(imgInd,1:2);
        ptsB=l2(tmpInd,1:2);
% Apply RANSAC to putative correspondences to get the transform
        [inliers, ransacWarp]=iat_ransac(iat_homogeneous_coords(ptsB'),iat_homogeneous_coords(ptsA'),...
        'homography', 'tol',.05, 'maxInvalidCount', 10);
% Create mosaic
        ransacMosaic = iat_mosaic(tmp,img,ransacWarp);
 
%% Moving object detection using background subtraction and frame differencing (Part2 Part 3)
% Gaussian Filter Speciifications
%These determine the size of filter (propotinal to its magnitude)
        hsizeh = 28;  
        sigmah = 12 ; 
        h = fspecial('log', hsizeh, sigmah);
% Iteratively (frame by frame) find moving object and save the X Y coordinates!
        %X = cell(1,length(f_list)); %detection X coordinate indice
        %Y = cell(1,length(f_list));  %detection Y coordinate indice
% Motion Tracking
% Reading Frame
     img_rea = (imread(f_list(i).name));
% Adjust Brigtness to better detect object
     img_real=imadjust(img_rea,[.1 .1 0; .2 .2 1],[]);       
     img_tmp = double(img_real);
     img = img_tmp(:,:,1);       
% Applying filter to the image      
     blob_img = conv2(img,h,'same');
% Thresholding
     idx = find(blob_img < 0.3);       
     blob_img(idx) = nan ;
% Finding the extremas     
     [b,a,zmax,zmin] = imextrema(blob_img); 
% Getting their coordinates
     g(i)=length(a);                      
     clf
     bugnum = {length(a)};
% Cropping the mosaic to remove unwanted piece
     im1=uint8(ransacMosaic);
     im2=im1(:,1:600,:);
% Plotting result frame by frame
     subplot(2,2,1); imshow(img_rea);title('Present Frame');
     subplot(2,2,3); imshow(blob_img);title('Detected Object'); 
     subplot(2,2,2);imagesc(im2);title('Mosaic Forming');
     subplot(2,2,4);imshow(tmp);title('Object Tracking'); 
% Printing Number of objects detected and the Object itself
     hold on
     text(3,16,bugnum,'FontSize',20);
     for j = 1:length(a)
        plot(b(j),a(j), 'c+:');
     end
     pause(.01)
     axis off
   end;

     out = sc(blob_img);
     im1=uint8(ransacMosaic);
     im2=im1(:,1:600,:);
     figure;
     subplot(2,1,1),imagesc(im2);
     title('Mosaic after feature-based alignment (RANSAC-homography)');
     subplot(2,1,2), hist(out);  
     title('Histogram');
     

