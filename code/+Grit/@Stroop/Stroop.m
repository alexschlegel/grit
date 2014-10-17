classdef Stroop < PTB.Object

    % Implementation of the Stroop task to practice the +PTB framework
    %
    % Syntax: st = Stroop(<options>)
    %
    % In:
    %   <options>:
    %    debug: (0) debug mode
    
    % PUBLIC PROPERTIES----------------------------------------------%
    properties
        exp;
    end
    % PUBLIC PROPERTIES----------------------------------------------%
    
    % PRIVATE PROPERTIES---------------------------------------------%
    properties (SetAccess=private, GetAccess=private)
        argin;
    end        
    % PUBLIC METHODS-------------------------------------------------%
    methods
        function st = Stroop(varargin)
            st = st@PTB.Object([], 'stroop');
            
            st.argin = varargin;
            
            opt = ParseArgs(varargin, 'debug', 0);
            
            opt.name = 'stroop';
            opt.input_scheme = 'lrud';            
            opt.text_size = ST.Param('text', 'instructSize');
            opt.text_color = ST.Param('text', 'color');
            
            % window
            opt.background = ST.Param('color','back');
            
            % pass options to the experiment
            cOpt = Opt2Cell(opt);
            st.exp = PTB.Experiment(cOpt{:});
                        
            %start
            st.Start;
            
            % autorun
            st.Run(opt.debug);
        end
        %-------------------------------------------------------%
        function Start(st,varargin)
            st.argin = append(st.argin, varargin);
            
        end
        %--------------------------------------------------------%
        function End(st,varargin)
            v = varargin;
            
            st.exp.End(v{:});
        end
    end
    
end