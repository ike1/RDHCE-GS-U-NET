function [modified_histogram] = IsaacSplitHistogram(histogram, threshold)
    % Start with the original histogram
    New_Histo = histogram;
    histo_size = length(histogram);
    
    % Loop through the histogram from left to right (1 to 256)
    for bin = 1:histo_size-1
        % Get the pixel count of the current bin and the next bin
        peak_pixel_count = New_Histo(1, bin);
        right_bin_pixel_count = New_Histo(1, bin + 1);
        
        % Check if the peak bin's pixel count is greater than the threshold
        % and if the right bin's pixel count is less than half of the peak bin
        if peak_pixel_count > threshold && right_bin_pixel_count < peak_pixel_count / 2
            % Calculate the amount to split (half of the peak bin's pixel count)
            split_amount = floor(peak_pixel_count / 2);
            
            % Split the peak bin and add to the right bin
            New_Histo(1, bin) = New_Histo(1, bin) - split_amount;   % Subtract from the peak bin
            New_Histo(1, bin + 1) = New_Histo(1, bin + 1) + split_amount;  % Add to the right bin
            
            disp(['Splitting Bin ', num2str(bin), ':', ...
                  ' Peak Bin Pixel Count = ', num2str(peak_pixel_count), ', ' ...
                  'Split Amount = ', num2str(split_amount), ...
                  ' to Bin ', num2str(bin + 1)]);
            
            break;  % Exit the loop after performing the split
        end
    end
    
    % Return the modified histogram
    modified_histogram = New_Histo;

    % Display the modified histogram
    figure;  % Create a new figure window
    bar(modified_histogram);  % Create a bar plot of the modified histogram
    title('Modified Histogram');
    xlabel('Bins');
    ylabel('Pixel Count');
    
    x=1;
end
