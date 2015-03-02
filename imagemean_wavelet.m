%Author: Chris Etler
%Description: Takes a image and compresses it by converted it into small
%blocks with dimensions specified by $blocksize, and using the mean color
%value for each block as the output color for that section of the image
%
%Essentially this is an image-pixelator
clear;
tic;
%image to be used
image_name = 'ocean.png';
a = imread(image_name);
bw = rgb2gray(a);
Q = 16;
% width and height
% z is the number of channels
[y,x,z] = size(a);

%generates the output file
%uint8 because color values go typically from 0-255
aout = uint8(zeros(y,x,z));

%how big of an area to break the image up into
%bigger => blockier image
boxsize = 8;

num_blocks_n = ceil(x / boxsize);
num_blocks_m = ceil(y / boxsize);

c = Q.*floor(a/Q);


%goes through the image block by block
%n is columns
for n = 1:(num_blocks_n);
    %m is rows
    for m = 1:(num_blocks_m);
        n_offset = (n-1)*boxsize+1;
        m_offset = (m-1)*boxsize+1;

        %sets the box size. Should be $boxsize * $boxsize but this makes sure it hasn't gotten
        %to the end of the image and thus have to make the box smaller.
        
        if (n_offset+boxsize > x)
            box_x = x-n_offset;
        else
            box_x = boxsize;
        end
        
        if (m_offset+boxsize > y)
            box_y = y-m_offset;
        else
            box_y = boxsize;
        end
        
        %matrix for the current box
        box_mat = a((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x), 1:z);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%   The math for the specific algorith   %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %get the 2D DCT of the current box, channel-by-channel
        for channel = 1:z
            %curr_box(:,:,channel) = dct2(box_mat(:,:,channel));
            %a_DCT((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x),channel) = curr_box(:,:,channel);
            [cA(:,:,channel),cH(:,:,channel),cV(:,:,channel),cD(:,:,channel)] = dwt2(box_mat(:,:,channel),'sym4');
            cA = Q * round(cA/Q);
            cH = Q * round(cH/Q);
            cV = Q * round(cV/Q);
            cD = Q * round(cD/Q);
            box_x_n = size(cA,2);
            box_y_n = size(cA,1);
            A_n((m_offset):(m_offset+box_y_n-1), (n_offset):(n_offset+box_x_n-1), channel) = cA(:,:,channel);
            H_n((m_offset):(m_offset+box_y_n-1), (n_offset):(n_offset+box_x_n-1), channel) = cH(:,:,channel);
            V_n((m_offset):(m_offset+box_y_n-1), (n_offset):(n_offset+box_x_n-1), channel) = cV(:,:,channel);
            D_n((m_offset):(m_offset+box_y_n-1), (n_offset):(n_offset+box_x_n-1), channel) = cD(:,:,channel);
            aout((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x), channel) = idwt2(cA(:,:,channel),cH(:,:,channel),cV(:,:,channel),cD(:,:,channel),'sym4',size(box_mat));
        end
        %treshold the values
        %a_DCT(abs(a_DCT) < 10) = 0;
        %for channel = 1:z
            %curr_box(:,:,channel) = a_DCT_n((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x),channel);
            %curr_box = sign(curr_box) .* Q .* round(abs(curr_box)/Q);
            %aout((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x), channel) = idct2(curr_box(:,:,channel));

        %end
        clear('curr_box');
        clear('cA');
        clear('cH');
        clear('cV');
        clear('cD');
    end    
end
toc