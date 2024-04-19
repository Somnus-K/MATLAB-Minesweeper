function MineSweeper()
    rows = input('Enter number of rows: ');
    cols = input('Enter number of columns: ');
    num_mines = input('Enter number of mines: ');
    
    % Generate Minesweeper board
    board = generate_minesweeper_board(rows, cols, num_mines);
    
    % Display the board
    display_board(board);

    display_board_images(board);
end

function board = generate_minesweeper_board(rows, cols, num_mines)
    % Initialize the board
    board = repmat(' ', rows, cols);
    
    % Place mines randomly
    mines_placed = 0;
    while mines_placed < num_mines
        row = randi(rows);
        col = randi(cols);
        if board(row, col) ~= '*'
            board(row, col) = '*';
            mines_placed = mines_placed + 1;
        end
    end
    
    % Fill in numbers indicating the number of neighboring mines
    for r = 1:rows
        for c = 1:cols
            if board(r, c) == ' '
                count = count_neighbor_mines(board, r, c, rows, cols);
                if count > 0
                    board(r, c) = num2str(count);
                else
                    board(r,c) = num2str(0);
                end
            end
        end
    end
end

function count = count_neighbor_mines(board, row, col, rows, cols)
    count = 0;
    for r = max(1, row - 1):min(rows, row + 1)
        for c = max(1, col - 1):min(cols, col + 1)
            if board(r, c) == '*'
                count = count + 1;
            end
        end
    end
end

function display_board(board)
    disp(board);
end

function display_board_images(board)
    % Load images
    im0 = imread('0.png');
    im1 = imread('1.png');
    im2 = imread('2.png');
    im3 = imread('3.png');
    im4 = imread('4.png');
    im5 = imread('5.png');
    im6 = imread('6.png');
    im7 = imread('7.png');
    im8 = imread('8.png');
    imMine = imread('seamine.png');

    im0 = flipdim(im0 ,1); 
    im1 = flipdim(im1 ,1);
    im2 = flipdim(im2 ,1); 
    im3 = flipdim(im3 ,1); 
    im4 = flipdim(im4 ,1); 
    im5 = flipdim(im5 ,1); 
    im6 = flipdim(im6 ,1); 
    im7 = flipdim(im7 ,1); 
    im8 = flipdim(im8 ,1); 
    imMine = flipdim(imMine ,1); 


    % Define mapping from board values to images
    image_map = {'0', im0; '1', im1; '2', im2; '3', im3; '4', im4; '5', im5; '6', im6; '7', im7; '8', im8; '*', imMine};

    % Calculate total size required for the grid
    [rows, cols] = size(board);
    image_size = 200;  % Assuming all images are 200px by 200px
    total_width = cols * image_size;
    total_height = rows * image_size;

    % Set up the figure window with fixed size
    fig = figure('Units', 'pixels', 'Position', [100, 100, total_width, total_height], 'Resize', 'off');

    % Create axes to hold images
    ax = axes('Units', 'pixels', 'Position', [0, 0, total_width, total_height], 'Visible', 'off');

    % Display images
    for r = rows:-1:1 % Invert row iteration
        for c = 1:cols
            % Get the corresponding image for the current cell value
            current_image = image_map{strcmp(board(r, c), image_map(:, 1)), 2};
            % Calculate position for the image
            x_start = (c - 1) * image_size + 1;
            y_start = (rows - r) * image_size + 1; % Adjusted y-coordinate calculation
            % Display the image
            image('CData', current_image, 'XData', [x_start, x_start + image_size - 1], 'YData', [y_start, y_start + image_size - 1], 'Parent', ax);
        end
    end

    % Define callback function for click event
    set(fig, 'WindowButtonDownFcn', @imageClicked);

    function imageClicked(~, ~)
        % Get mouse click coordinates
        click_point = get(ax, 'CurrentPoint');
        x = click_point(1,1);
        y = click_point(1,2);
        % Convert coordinates to row and column indices
        col = ceil(x / image_size);
        row = rows - ceil(y / image_size) + 1; % Adjusted y-coordinate and row index calculation
        % Print clicked message
        disp(['Image clicked at coordinates: ', num2str(row), ',', num2str(col)]);
    end
end