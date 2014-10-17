function effect = StroopEffect(param, result)
% Grit.ST.StroopEffect
%
% Calculates the extent of the Stroop effect after a Stroop Task run.
% (Stroop effect: rt(incongruent) > rt(congruent) on correct trials)
%
% Uses an unpaired t-test of the reaction times for correct trials.

bCorrect = result.correct;
bCongruent = param.congruent;

rtCorrect = result.rt(bCorrect);
bCongruentCorrect = bCongruent(bCorrect);

rtCongruentCorrect = rtCorrect(bCongruentCorrect);
rtIncongruentCorrect = setdiff(rtCorrect, rtCongruentCorrect);

[h, p, ci, stats] = ttest2(rtIncongruentCorrect, rtCongruentCorrect, 0.05, 'right');

effect = struct('h', h, 'p', p, 'ci', ci, 'stats', stats, 'rtCongruent', rtCongruentCorrect, 'rtIncongruent', rtIncongruentCorrect);
