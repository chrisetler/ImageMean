%Author: Chris and David Etler
%Description: Takes a image and compresses it by converted it into small
%blocks with dimensions specified by $blocksize, and using the mean color
%value for each block as the output color for that section of the image
%
%Essentially this is an image-pixelator

%%OUTPUTS
%   aout -- compressed JPEG image
%   a_DCT_n -- DCT of compressed JPEG image
%   aout_un -- lossless JPEG image (should be the same as a)
%   a_DCT -- DCT of lossless JPEG
%   c -- a quantized in spacial domain

%%PARAMETERS
%   Q -- quantizing factor
%   image_name -- file name of image
%   boxsize -- size of boxes (recommended 3)
clear;

% Quantizing constant (lower number = higher quality)
Q = 16;

%image to be used
image_name = 'ocean.png';
a = imread(image_name);
bw = rgb2gray(a);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               ENCODING                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1:(num_blocks_n);
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
        for(channel = 1:z)
            curr_box = dct2(box_mat(:,:,channel));
            a_DCT((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x),channel) = curr_box;
            aout_un((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x),channel) = idct2(curr_box);
            curr_box = Q.*round(abs(curr_box)/Q).*sign(curr_box);
            a_DCT_n((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x),channel) = curr_box;
            aout((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x),channel) = idct2(curr_box);
        end
    end
end



      