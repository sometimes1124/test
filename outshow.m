load out.dat
out = uint8(out);
out = reshape(out, [1024, 768]);
imshow(out', [0,255]);
