function [pixelCounts, splittingInfo] = Isaac_splitAndRedistribute(pixelCounts, adaptiveThreshold)
    % Initialize structure to record splitting information
    splittingInfo = struct('bin', [], 'splitValue', [], 'neighbor', []);

    % Loop through bins to check for overcrowded bins
    for i = 1:length(pixelCounts)
        % Check if the current bin is overcrowded
        if pixelCounts(i) > adaptiveThreshold
            % Split the bin value
            splitValue = pixelCounts(i) / 2;
            pixelCounts(i) = splitValue; % Remaining pixels in the current bin

            % Initialize variables for tracking the neighbor bin
            neighborBin = -1;

            % Determine which neighbor to redistribute to
            if i < length(pixelCounts) && pixelCounts(i + 1) < pixelCounts(i)
                % Add to the right neighbor if it has fewer pixels
                pixelCounts(i + 1) = pixelCounts(i + 1) + splitValue;
                neighborBin = i + 1;
            elseif i > 1 && pixelCounts(i - 1) < pixelCounts(i)
                % Otherwise, add to the left neighbor if it has fewer pixels
                pixelCounts(i - 1) = pixelCounts(i - 1) + splitValue;
                neighborBin = i - 1;
            end

            % Record split information
            if neighborBin > 0
                % Record the split bin index
                splittingInfo(end + 1).bin = i; 
                 % Record the split value
                splittingInfo(end).splitValue = splitValue;
                % Record the neighbor bin index
                splittingInfo(end).neighbor = neighborBin; 
            end
        end
    end
end


