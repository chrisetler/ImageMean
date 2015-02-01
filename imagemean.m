%Author: Chris Etler
%Description: Takes a image and compresses it by converted it into small
%blocks with dimensions specified by $blocksize, and using the mean color
%value for each block as the output color for that section of the image
%
%Essentially this is an image-pixelator
clear;
image_name = '1.png';

a = imread(image_name);
% width and height
% z is the number of channels. Right now 3 is hardcoded in but that could
% be easily changed to 'z' in the near future to allow for grayscale alpha
% images to work.
[y,x,z] = size(a);



%how big of an area to break the image up into
%bigger => blockier image
boxsize = 10;
num_blocks_n = ceil(x / boxsize);
num_blocks_m = ceil(y / boxsize);
%generates the output file
%uint8 because color values go typically from 0-255
aout = uint8(zeros(y,x,3));

%goes through the image block by block
for n = 1:(num_blocks_n);
    for m = 1:(num_blocks_m);
        n_offset = (n-1)*boxsize+1;
        m_offset = (m-1)*boxsize+1;

        %crops the image to a square with side lengths of $blocksize
        %b = imcrop(a, [n m n+boxsize m+boxsize]);


        %get the mean for each channel in the box
        channel_sum = uint64(zeros(1,3));
        mean = zeros(1,3);
        %for channel = 1:1:3;
            if(n ~= num_blocks_n && m ~= num_blocks_m);
                box_mat = a((m_offset):(m_offset+boxsize), (n_offset):(n_offset+boxsize), 1:3);
                channel_sum = sum(sum(box_mat));
                box_x = boxsize;
                box_y = boxsize;
                channel_length = (boxsize+1)*(boxsize+1);
            else
                box_mat = a((m_offset):y, (n_offset):x, 1:3);
                channel_sum = sum(sum(box_mat));
                box_x = x - n_offset;
                box_y = y - m_offset;
                channel_length = (y - m_offset)*(x - n_offset);
     
            end
        for channel = 1:1:3;
            mean(channel) = channel_sum(channel) ./ channel_length;
        end
        
        %The math for the specific algorith
        %produce an image using only the mean value
        box_mat = box_mat.*0;
        box_mat = box_mat+1;
        for i = 1:1:3;
           
            box_mat(:,:,i) = uint8(mean(i)).*box_mat(:,:,i);
        end
        
        
        %for channel = 1:1:3;   
            %aout((1:box_y) + m_offset,(1:box_x) + n_offset,channel) = uint8(box_mat(channel));
        if(n ~= num_blocks_n && m ~= num_blocks_m);
            aout((m_offset):(m_offset+boxsize), (n_offset):(n_offset+boxsize),1:3) = uint8(box_mat);
        else 
            aout((m_offset):y, (n_offset):x,1:3) = uint8(box_mat);
        end
            
        %end
    end
end


      