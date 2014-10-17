function p = Param(varargin)
% Grit.ST.Param
%
% Description: get a stroop parameter
global SIZE_MULTIPLIER;
persistent P;

if isempty(SIZE_MULTIPLIER)
    SIZE_MULTIPLIER = 1;
end

if isempty(P)
    % stimulus parameters
    P.color = struct(...
        'back'  ,   'black'     ...
        );                
    P.text = struct(...
        'instructSize'  ,   SIZE_MULTIPLIER, ...
        'wordSize'      ,   1.7*SIZE_MULTIPLIER, ...
        'color' ,   'gray'  ...
        );
    % colors and response buttons
    % number of unique trials = 2*(num colors)*(num colors - 1)
%     P.response = struct(...
%         'yellow',  'up'   ,   ... % corresponds to 1st, 2nd and 3rd
%         'blue'  ,  'left' ,   ... % color or word (e.g. red, green, blue)
%         'red'   ,  'right',   ...
%         'green' ,  'down'     ... 
%         );
    P.response = struct(...
        'blue'  , 'left'    , ...
        'green' , 'down'    , ...
        'red'   , 'right'     ...
        );
%     P.gpButton = {'Y';'X';'B';'A'};
    P.gpButton = {'X';'A';'B'};
end

p = P;

for k=1:nargin
    v = varargin{k};
    
    switch class(v)
        case 'char'
            switch v
                case 'sizemultiplier'
                    p = SIZE_MULTIPLIER;
                case 'trialspercond'
                    p = 12;
                case 'npracticetrials' % must be < # of colors squared
                    p = 5;
                case 'restperiod'
                    p = .3;
                otherwise
                    if isfield(p,v)
                        p = p.(v);
                    else
                        p = [];
                        return
                    end
            end
        otherwise
            if iscell(p)
                p = p{v};
            else
                p = [];
                return
            end
    end
end