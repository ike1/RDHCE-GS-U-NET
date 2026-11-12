function [recoveredPixelCounts, recoveredImage] = Isaac_recoverHistogram(splittingInfo, newPixelCounts, gray, intensityLevels)
    % Initialize recovered pixel counts
    recoveredPixelCounts = zeros(size(newPixelCounts));
    
    % Restore the original histogram based on splitting information
    for i = 1:length(splittingInfo)
        splitBin = splittingInfo(i).bin; % The bin that was split
        splitValue = splittingInfo(i).splitValue; % The split value
        neighborBin = splittingInfo(i).neighbor; % The neighbor bin that received the split value
        
        % Restore the original bin count
        recoveredPixelCounts(splitBin) = recoveredPixelCounts(splitBin) + splitValue;
        recoveredPixelCounts(neighborBin) = recoveredPixelCounts(neighborBin) - splitValue; % Subtract from neighbor
    end

    % Reconstruct the recovered image from the recovered pixel counts
    recoveredImage = zeros(size(gray), 'uint8');
    
    for i = 1:length(intensityLevels)
        recoveredImage(gray == intensityLevels(i)) = round(recoveredPixelCounts(i));
    end
end
    