%{
change grid line thickness on resize?


undo?
-complicated to undo flip
%}
function [] = Othello()
	f = [];
	ax = [];
	w = 500;
	bp = [];
	wp = [];
	player = 1;
	board = [];
	pot = [];
	gameOver = false;
	score = [];
	ng = [];
	
	figureSetup();
	firstGame();
	
	
	function [] = click(~,~)
		if gameOver
			return
		end
		
		m = round(ax.CurrentPoint([1,3])); % gives col, row
		
		if m(2)<=size(board,1) && m(1)<=size(board,2) && board(m(2),m(1))==0 %empty square within board
			go = false;
			for i=1:length(pot.XData) % guarantees flip
				if m(1)==pot.XData(i) && m(2)==pot.YData(i)
					go = true;
					break
				end
			end
			if ~go % moves must flip tiles
				return
			end

			board(m(2),m(1)) = player;
			flip(m);
% 			length(wp.XData)
			score.String = sprintf('Black: %2d  White: %2d',length(bp.XData), length(wp.XData));
			
			player = -player;
			if nnz(board)~=numel(board) % check if full
				%check for moves
				[moveable, moves] = moveCheck();% check if player can move
				if moveable 
					[r,c] = ind2sub(size(board),moves);
				else
					player = -player;
					[moveable, moves] = moveCheck(); %check if other player can move
					if moveable
						[r,c] = ind2sub(size(board),moves);
					else
						r = [];
						c = [];
						gameOver = true;
						%no one can make a move, game over
					end
				end
			else
				r = [];
				c = [];
				%board full, game over
				gameOver = true;
			end
			pot.XData = c;
			pot.YData = r;
			pot.MarkerFaceColor = ones(1,3)*(player==-1);
		end
	end
	
	function [bool, moves] = moveCheck()
		% get empty squares adjacent to filled pieces (opp color pieces)
		% -- check each to see if it would cause a flip
		moves = [];
		for i=1:numel(board)
			if board(i)==0
				[r, c] = ind2sub(size(board),i);
				for j=0:pi/4:7*pi/4 % check each dir for adjacents
					dx = round(cos(j));
					dy = round(sin(j));
					x = c + dx;
					y = r + dy;
					if x>0 && x<9 && y>0 && y<9 && board(y,x)==-player %there is an adjacent -player
						while x>0 && x<9 && y>0 && y<9 && board(y,x)==-player %track trail
							x = x + dx;
							y = y + dy;
						end
						if x>0 && x<9 && y>0 && y<9 && board(y,x)==player % trail ends with player
							moves(end+1) = i;
							break %no need to check other dirs now
						end
					end
				end
			end
		end
		bool = ~isempty(moves);
	end
	
	function [] = flip(m)
		%{
		check for adjacent squares of opposite color
		--where found, travel to find same color
		----flip all in-between
		%}
		for i = 0:pi/4:7*pi/4
			dx = round(cos(i));
			dy = round(sin(i));
			x = m(1) + dx;
			y = m(2) + dy;
			if x>0 && x<9 && y>0 && y<9 && board(y,x)==-player %check for adjacent squares of opposite color
				while x>0 && x<9 && y>0 && y<9 && board(y,x)==-player %--where found, travel to find same color
					x = x + dx;
					y = y + dy;
				end
				if x>0 && x<9 && y>0 && y<9 && board(y,x)==player %----flip all in-between
					x = x - dx;
					y = y - dy;
					while  board(y,x)==-player
						board(y,x) = player;
						x = x - dx;
						y = y - dy;
					end
					
					% update black tiles
					j = find(board==1);
					bp.XData = zeros(1,length(j));
					bp.YData = zeros(1,length(j));
					for k = 1:length(j)
						[r,c] = ind2sub(size(board),j(k));
						bp.XData(k) = c;
						bp.YData(k) = r;
					end
					
					% update white tiles
					j = find(board==-1);
					wp.XData = zeros(1,length(j));
					wp.YData = zeros(1,length(j));
					for k = 1:length(j)
						[r,c] = ind2sub(size(board),j(k));
						wp.XData(k) = c;
						wp.YData(k) = r;
					end
					
				end
			end
		end
	end
	
	function [] = newGame(~,~)
		bp.XData = [4 5];
		bp.YData = [4 5];
		wp.XData = [5 4];
		wp.YData = [4 5];
		pot.XData = [3 4 5 6];
		pot.YData = [5 6 3 4];
		pot.MarkerFaceColor = [0 0 0]; %unless i want to vary who starts
		
		player = 1;
		board = zeros(8);
		board([28, 37]) = 1;
		board([29, 36]) = -1;
		gameOver = false;
		score.String = sprintf('Black: %2d  White: %2d',2, 2);
	end
	
	function [] = firstGame()
		l = matlab.graphics.primitive.Line.empty;
		for i=0.5:8.5
			l(end+1) = line([0.5 8.5], [i i]);
			l(end+1) = line([i i], [0.5 8.5]);
		end
		for i=1:length(l)
			l(i).LineWidth = 2;
			l(i).Color = [0 0 0];
		end
		
		bp = plot([4 5], [4 5],'o','MarkerFaceColor',[0 0 0],'MarkerSize',30,'MarkerEdgeColor','none');
		wp = plot([5 4], [4 5],'o','MarkerFaceColor',[1 1 1],'MarkerSize',30,'MarkerEdgeColor','none');
		pot = plot([3 4 5 6],[5 6 3 4],'o','MarkerFaceColor',[0 0 0],'MarkerSize',15,'MarkerEdgeColor','none');

		newGame();
	end
	
	function [] = figureSetup()
		f = figure(1);
		clf
		f.MenuBar = 'none';
		f.Name = 'Othello';
		f.NumberTitle = 'off';
		f.Position = [200 150, w w];
		f.WindowButtonUpFcn = @click;
		f.SizeChangedFcn = @resize;
		
		ax = axes('Parent',f);
		ax.Position = [0.05 0.05 0.9 0.9];
		ax.GridAlpha = 1;
		axis equal
		axis([0.5 8.5 0.5 8.5])
		ax.YDir = 'reverse';
		ax.NextPlot = 'add';
		ax.Color = [0 0.5 0];
		ax.XTick = [];
		ax.YTick = [];
		
		score = uicontrol(...
			'Parent',f,...
			'Style','text',...
			'String',sprintf('Black: %d  White: %d',2, 2),...
			'Units','normalized',...
			'Position',[0 0.955 1 0.04],...
			'FontSize',12,...
			'HorizontalAlignment','center',...
			'FontName','FixedWidth');
		ng = uicontrol(...
			'Parent',f,...
			'Style','pushbutton',...
			'Units','normalized',...
			'Position',[0.375 0.005, 0.25 0.04],...
			'String', 'New Game',...
			'FontSize',12,...
			'Callback',@newGame);
	end
	
	function [] = resize(~,~)
		if ~isvalid(ax) %is an issue when hitting run when fig is already open
			return
		end
		ax.Units = 'pixels';
		scale = min(ax.Position(3:4))/w;
		ax.Units = 'normalized';
		
		score.FontSize = 12*scale;
		ng.FontSize = 12*scale;
		bp.MarkerSize = 30*scale;
		wp.MarkerSize = 30*scale;
		pot.MarkerSize = 15*scale;
	end
end



