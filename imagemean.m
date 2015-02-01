%Author: Chris Etler
%Description: Takes a image and compresses it by converted it into small
%blocks with dimensions specified by $blocksize, and using the mean color
%value for each block as the output color for that section of the image
%
%Essentially this is an image-pixelator


a = imread('1.png');
% width and height
% z is the number of channels. Right now 3 is hardcoded in but that could
% be easily changed to 'z' in the near future to allow for grayscale alpha
% images to work.
[y,x,z] = size(a);

%generates the output file
%uint8 because color values go typically from 0-255
aout = uint8(zeros(y,x,3));

%how big of an area to break the image up into
%bigger => blockier image
boxsize = 10;


%goes through the image block by block
for n = 1:boxsize:x;
    for m = 1:boxsize:y;


        %crops the image to a square with side lengths of $blocksize
        b = imcrop(a, [n m n+boxsize m+boxsize]);


        %get the mean for each channel in the box
        sum = uint64(zeros(1,3));
        len = zeros(1,3);
        mean = zeros(1,3);
        for channel = 1:1:3;
            for i = 1:1:boxsize;
                for j = 1:1:boxsize;
                    if (i+n) <= x && (j+m)<= y;
                        sum(channel) = sum(channel) + uint64(b(j,i,channel));
                        len(channel) = len(channel) +1;
                    end
                end
            end
            mean(channel) = sum(channel) / len(channel);
        end

        %produce an image using only the mean value
        
        for channel = 1:1:3;
            for i = 1:1:boxsize;
                for j = 1:1:boxsize;
                    aout(m+j-1,n+i-1,channel) = uint8(mean(channel));
                end
            end
        end
    end
end


      