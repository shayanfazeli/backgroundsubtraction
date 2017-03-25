function out = normalizer(image)
    image = image - min(min(min(image)));
    image = 255*(image/max(max(max(image))));
    out = uint8(image);

end