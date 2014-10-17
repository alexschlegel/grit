function Run(st, debug)
% Stroop.Run
%
% Description: do the next Stroop run
%
% In:
%   st: the stroop task object
%   debug: the debug mode
%
% Syntax: st.Run
% 

sButton = ST.Param('response');
cColor = fieldnames(sButton);
cKey = struct2cell(sButton);
cGPButton = ST.Param('gpButton');

% key mappings
cellfun(@(name,but) st.exp.Input.Set(name,but), cColor, cKey);
kButton = cellfun(@(but) cell2mat(st.exp.Input.Get(but)), cColor);
st.exp.Input.Set('any_response', reshape(cColor, 1, []));
if debug < 2
    st.exp.Input.Set('close_window', {'lupper';'back';'y'});
else
    st.exp.Input.Set('close_window', {'left';'right'});
end

% matrix that determines condition combinations
nWords = numel(cColor);     % normally should equal number of colors
% equalizes color and word occurance and congruency/incongruency.
condMatrixBase = [repmat(1:nWords,2,nWords-2) [sort(repmat(1:nWords,1,nWords));repmat(1:nWords,1,nWords)]];
practiceMatrixBase = condMatrixBase(:,nWords*(nWords-2)+1:nWords*(2*nWords-2));
if size(practiceMatrixBase, 2) ~= nWords^2
    error('oops, math error. Check generation of practice matrix.');
end

% Total number of trials = conditions * trialsPerCondition
trialsPerCondition = ST.Param('trialspercond');
condMatrix = repmat(condMatrixBase, 1, trialsPerCondition);
[~, numTrials] = size(condMatrix);

% Randomize trials
rng('shuffle');
shuffler = Shuffle(1:numTrials);
condMatrixShuffled = condMatrix(:, shuffler);

% Get practice trials
numPractice = ST.Param('npracticetrials');
rng('shuffle');
shuffler = Shuffle(1:nWords^2);
shuffler = shuffler(1:numPractice);
practiceMatrixShuffled = practiceMatrixBase(:, shuffler);

% Store data
result = struct('rt', NaN(numTrials, 1), 'response', {cell(numTrials, 1)},...
    'correct', false(numTrials,1));
st.exp.Info.Set('stroop', 'result', result);

param.word = cColor(condMatrixShuffled(1,:))';
param.color = cColor(condMatrixShuffled(2,:))';
param.congruent = strcmp(param.word, param.color);
st.exp.Info.Set('stroop', 'param', param);

% Display instructions
st.exp.Show.Instructions('You will see a series of words on the screen.', 'next', 'continue');
st.exp.Show.Instructions('Pay attention to the color of the word,\nnot the word itself.', 'next', 'continue');
st.exp.Show.Instructions('As quickly as you can,\npress the button for that color.', 'next', 'continue');
cKeyInstruct = cellfun(@(color,key) ['<color:' color '>word</color> ==> ' key '\n'], ...
    cColor, conditional(debug < 2, cGPButton, cKey), 'uni', false);
strKeyInstruct = cell2mat(cKeyInstruct');
st.exp.Show.Instructions(strKeyInstruct, 'next', 'continue');
st.exp.Show.Instructions('You will now have a short practice round.','next','begin');

% Pause scheduler
st.exp.Scheduler.Pause;

wordSize = ST.Param('text','wordSize');

% Run the practice
for pTrial = 1:numPractice
    word = cColor{practiceMatrixShuffled(1,pTrial)};
    color = cColor{practiceMatrixShuffled(2,pTrial)};
    st.exp.Show.Text(sprintf('<size:%s><color:%s>%s</color></size>', wordSize, color, word));
    st.exp.Window.Flip;
    bContinue = false;
    while ~bContinue        
        [bContinue, ~, ~, ~] = st.exp.Input.DownOnce('any_response');
        WaitSecs(.001);
    end
    st.exp.Show.Blank('fixation',false);  % blank the screen
    st.exp.Window.Flip;
    WaitSecs(ST.Param('restperiod'));
end

st.exp.Show.Instructions('End of practice round.','next', 'begin the experiment');

% Run the trials
for trial = 1:numTrials
    word = cColor{condMatrixShuffled(1,trial)};
    color = cColor{condMatrixShuffled(2,trial)};
    st.exp.Show.Text(sprintf('<size:%s><color:%s>%s</color></size>', wordSize, color, word));
    tStart = st.exp.Window.Flip;
    bContinue = false;
    while ~bContinue        
        [bContinue, ~, tRes, kPressed] = st.exp.Input.DownOnce('any_response');
        WaitSecs(.001);
    end
    st.exp.Show.Blank('fixation',false);  % blank the screen
    st.exp.Window.Flip;
    % Save results
    % Response time?
    result.rt(trial) = tRes-tStart;
    % Button pressed?
    strButton = cColor{ismember(kButton, kPressed(1))};
    result.response{trial} = strButton;
    % Correct?
    bCorrect = strcmp(color, strButton);
    result.correct(trial) = bCorrect;
    % Save
    st.exp.Info.Set('stroop', 'result', result);
    % Wait before the next stimulus
    WaitSecs(ST.Param('restperiod'));
end
fClose = @()deal(st.exp.Input.DownOnce('close_window'),false,PTB.Now);
st.exp.Show.Instructions('Finished! Please alert the experimenter.', ...
     'prompt', ' ', 'fresponse', fClose);
st.exp.Scheduler.Resume;
% Calculate the stroop effect
result.effect = ST.StroopEffect(st.exp.Info.Get('stroop','param'), result);
st.exp.Info.Set('stroop','result',result);
st.exp.End;
end