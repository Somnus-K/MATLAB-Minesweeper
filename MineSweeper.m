function hw()
    rows = input('Enter number of rows: ');
    cols = input('Enter number of columns: ');
    num_mines = input('Enter number of mines: ');
    
    % Generate Minesweeper board
    board = generate_minesweeper_board(rows, cols, num_mines);
    
    % Display the board
    display_board(board);
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