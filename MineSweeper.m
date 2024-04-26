function MineSweeper()
    rows = input('Enter number of rows: ');
    cols = input('Enter number of columns: ');
    num_mines = input('Enter number of mines: ');
    
    % Generate Minesweeper board
    board = generate_minesweeper_board(rows, cols, num_mines);
    
    % Display the board using images with hidden/reveal functionality
    display_board_images(board);
end

function board = generate_minesweeper_board(rows, cols, num_mines)
    % Initialize the board
    board = repmat('0', rows, cols);
    
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
            if board(r, c) ~= '*'
                board(r, c) = num2str(count_neighbor_mines(board, r, c, rows, cols));
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

function display_board_images(board)
    % Load images for all possible states
    imagesMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    % Create a map of images for the numbers 0 through 8 and the mine
    for i = 0:8
        imagesMap(char(i+'0')) = flipud(imread(sprintf('%d.png', i)));
    end
    imagesMap('*') = flipud(imread('seamine.png'));
    imagesMap('covered') = flipud(imread('covered.png'));  % Image for covered tiles
    imagesMap('flag') = flipud(imread('flag.png'));  % Image for flag

    [rows, cols] = size(board);
    image_size = 100;
    total_width = cols * image_size;
    total_height = rows * image_size;

    fig = figure('Units', 'pixels', 'Position', [100, 100, total_width, total_height], 'Resize', 'off');
    ax = axes('Units', 'pixels', 'Position', [0, 0, total_width, total_height], 'Visible', 'off');

    % Initialize revealed matrix
    revealed = false(rows, cols);
    flagged = false(rows, cols); 
    setappdata(fig, 'revealed', revealed);
    setappdata(fig, 'flagged', flagged);

    % Store image handles
    handles = zeros(rows, cols);

    for r = 1:rows
        for c = 1:cols
            x_start = (c - 1) * image_size;
            y_start = (rows - r) * image_size;
            img = imagesMap('covered'); % Start with all tiles covered
            handles(r, c) = image('CData', img, 'XData', [x_start, x_start + image_size], 'YData', [y_start, y_start + image_size], 'Parent', ax);
        end
    end

    set(fig, 'WindowButtonDownFcn', @(src, event) imageClicked(src, event, handles, board, rows, cols, image_size, imagesMap));
end 

function imageClicked(src, event, handles, board, rows, cols, image_size, imagesMap)
    revealed = getappdata(src, 'revealed');
    flagged = getappdata(src, 'flagged');
    click_point = get(gca, 'CurrentPoint');
    col = floor(click_point(1,1) / image_size) + 1;
    row = rows - floor(click_point(1,2) / image_size);
    clickType = get(src, 'SelectionType'); % Detects type of mouse click
    
    % Check if the click is within bounds and not revealed
    if row > 0 && row <= rows && col > 0 && col <= cols
        if strcmp(clickType, 'alt') && ~revealed(row, col) % Right-click and not revealed
            toggleFlag(row, col);
        elseif strcmp(clickType, 'normal') && ~revealed(row, col) && ~flagged(row, col) % Left-click, not revealed, not flagged
            revealTile(row, col);
        end
    end

    setappdata(src, 'revealed', revealed);
    setappdata(src, 'flagged', flagged);

    function toggleFlag(r, c)
        if flagged(r, c)
            flagged(r, c) = false;
            set(handles(r, c), 'CData', imagesMap('covered')); % remove flag, display covered
        else
            flagged(r, c) = true;
            set(handles(r, c), 'CData', imagesMap('flag')); % flag 
        end
    end

    function revealTile(r, c)
       if board(r, c) == '0' && ~revealed(r, c) 
            % Start flood fill from here
            floodFill(r, c);
        elseif board(r, c) ~= '*'
            % Reveal non-mine and non-zero tiles immediately
            revealed(r, c) = true;
            set(handles(r, c), 'CData', imagesMap(board(r, c)));
       elseif board(r, c) == '*'
            revealAllMines();
        end
        disp(['Tile revealed at ', num2str(r), ',', num2str(c)]);
    end

    function floodFill(r, c)
        if r < 1 || r > rows || c < 1 || c > cols || revealed(r, c) || board(r, c) == '*'
            return;
        end
        revealed(r, c) = true;
        set(handles(r, c), 'CData', imagesMap(board(r, c)));
        if board(r, c) == '0'
            % Recursive calls for adjacent cells
            floodFill(r-1, c);  % up
            floodFill(r+1, c);  % down
            floodFill(r, c-1);  % left
            floodFill(r, c+1);  % right
            floodFill(r-1, c-1);  % up-left
            floodFill(r-1, c+1);  % up-right
            floodFill(r+1, c-1);  % down-left
            floodFill(r+1, c+1);  % down-right
        else
            % If it's a number, reveal it and stop
            revealTile(r, c);
        end
    end

    function revealAllMines()% Reveal all mines and display game over message
        for i = 1:rows
            for j = 1:cols
                revealed(i, j) = true;
                set(handles(i, j), 'CData', imagesMap(board(i, j)));
            end
        end
        msgbox('Game over! You clicked on a mine.', 'Boom!', 'error');
    end
end
