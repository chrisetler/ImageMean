%Author: Chris Etler
%Description: Takes a image and compresses it by converted it into small
%blocks with dimensions specified by $blocksize, and using the mean color
%value for each block as the output color for that section of the image
%
%Essentially this is an image-pixelator
clear;

%image to be used
image_name = '1.png';
a = imread(image_name);

% width and height
% z is the number of channels
[y,x,z] = size(a);

%generates the output file
%uint8 because color values go typically from 0-255
aout = uint8(zeros(y,x,3));

%how big of an area to break the image up into
%bigger => blockier image
boxsize = 10;

num_blocks_n = ceil(x / boxsize);
num_blocks_m = ceil(y / boxsize);


%goes through the image block by block
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
        box_mat = a((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x), 1:3);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%   The math for the specific algorith   %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %gets the sum of values and the total number of values, to obtain
        %the mean value
        channel_sum = sum(sum(box_mat));
        channel_length = box_x.*box_y;
        mean = channel_sum ./ channel_length;
        
        %produce a matrix uses the mean values for each channel
        box_mat = box_mat.*0;
        box_mat = box_mat+1;
        for i = 1:1:3;
            box_mat(:,:,i) = (mean(i)).*box_mat(:,:,i);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%      END math for specific algorithm      %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %output the box matrix to it's coordinates on the final image
        aout((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x), 1:3) = uint8(box_mat);
    
    end
end


      