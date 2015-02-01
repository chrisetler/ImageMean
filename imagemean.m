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

        %channel_sum = uint64(zeros(1,3));
        %mean = zeros(1,3);
            %if(n ~= num_blocks_n && m ~= num_blocks_m);
            if((n_offset+boxsize) <= x  && (m_offset+boxsize) <= y);
                box_mat = a((m_offset):(m_offset+boxsize), (n_offset):(n_offset+boxsize), 1:3);
                channel_sum = sum(sum(box_mat));
                box_x = boxsize;
                box_y = boxsize;
                channel_length = (boxsize+1)*(boxsize+1);
            else
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
                box_mat = a((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x), 1:3);
                channel_sum = sum(sum(box_mat));
                channel_length = box_x.*box_y;
     
            end
            
        %get the mean for each channel in the box
        %for channel = 1:1:3;
            mean = channel_sum ./ channel_length;
        %end
        
        %The math for the specific algorith
        %produce an image using only the mean value
        %does math on the block matrix and makes it ready for output, at
        %which point it is stitched on to the final image at the
        %appropriate position
        
        box_mat = box_mat.*0;
        box_mat = box_mat+1;
        for i = 1:1:3;
            box_mat(:,:,i) = (mean(i)).*box_mat(:,:,i);
        end
        
        
        %if(n ~= num_blocks_n && m ~= num_blocks_m);
        %if((n_offset+boxsize) <= x  && (m_offset+boxsize) <= y);
        %    aout((m_offset):(m_offset+boxsize), (n_offset):(n_offset+boxsize),1:3) = uint8(box_mat);
        %else 
        %    aout((y-boxsize-1):y, (x-boxsize-1):x, 1:3) = uint8(box_mat);
        %end
        aout((m_offset):(m_offset+box_y), (n_offset):(n_offset+box_x), 1:3) = uint8(box_mat);
    end
end


      