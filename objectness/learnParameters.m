function params = learnParameters(pathNewTrainingFolder, cues, ...
    dir_root, skip_precomputed)
%learns the parameters of the objectness function: theta_MS (for 5 scales),
%theta_CC, theta_ED, theta_SS and also the likelihoods corresp to each cue

%dir_root - path where the software is installed - see README Setting things up
if nargin < 3
    dir_root = [pwd '/'];
end
if nargin < 4
    skip_precomputed = false;
end

params = defaultParams(dir_root, 2);

if nargin == 1
    %train the parameters from another dataset
    params.trainingImages = pathNewTrainingFolder;
    origDir = pwd;
    cd(params.trainingImages);
    mkdir('Examples');
    cd(origDir);
end

if skip_precomputed && exist(fullfile('Data', 'learnMS.mat'), 'file')
    load(fullfile('Data', 'learnMS.mat'));
else
    %learn parameters for MS
    for idx = 1: length(params.MS.scale)
        scale = params.MS.scale(idx);
        params.MS.theta(idx) = learnThetaMS(params,scale);
    end

    try
        struct = load(fullfile(params.trainingImages, 'Examples', 'posnegMS.mat'));
        posnegMS = struct.posnegMS;
        clear struct;
    catch
        posnegMS = generatePosNegMS(params);
        save(fullfile(params.trainingImages, 'Examples', 'posnegMS.mat'),'posnegMS');
    end

    [likelihood, pObj] = deriveLikelihoodMS(posnegMS,params);
    save(fullfile(params.yourData, 'MSlikelihood.mat'),'likelihood');
    params.pObj = pObj;

end

%learn parameters for CC, ED, SS, OF, MO
if nargin < 2
    cues = {'CC','ED','SS', 'OF', 'MO'};
end

for cid = 1:length(cues)
    cue = cues{cid};
    [thetaOpt, likelihood, pobj] = learnTheta(cue,params);
    params.(cue).theta = thetaOpt;
    save(fullfile(params.yourData, sprintf('%slikelihood.mat', upper(cue))),'likelihood');
end

save(fullfile(params.yourData, '/params.mat'),'params');

end

% function posneg = generatePosNegMS(params)
% 
% if params.primary_type == params.TYPE_IMAGE
%     struct = load(fullfile(params.trainingImages, 'structGT.mat'));
% elseif params.primary_type == params.TYPE_VIDEO
%     struct = load(fullfile(params.trainingVideos, 'structGT.mat'));
% end
% structGT = struct.structGT;
% 
% for idx = length(structGT):-1:1
%     boxes = computeScores(structGT(idx),'MS',params);
%     posneg(idx).examples =  boxes(:,1:4);
%     labels = - ones(size(boxes,1),1);
%     for idx_window = 1:size(boxes,1)
%         for bb_id = 1:size(structGT(idx).boxes,1)
%             pascalScore = computePascalScore(structGT(idx).boxes(bb_id,:),boxes(idx_window,1:4));
%             if (pascalScore >= params.pascalThreshold)
%                 labels(idx_window) = 1;
%                 break;
%             end
%         end
%     end
%     posneg(idx).labels = labels;
%     posneg(idx).img = img;
%     posneg(idx).scores = boxes(:,5);
% end
% 
% end


function [likelihood, pobj] = deriveLikelihoodMS(posneg,params)

examplesPos = zeros(length(posneg) * params.distribution_windows,1);
examplesNeg = zeros(length(posneg) * params.distribution_windows,1);

pos = 0;
neg = 0;

for idx = 1:length(posneg)
    
    indexPositive = find(posneg(idx).labels == 1);
    examplesPos(pos+1:pos+length(indexPositive)) = posneg(idx).scores(indexPositive);
    pos = pos + length(indexPositive);
    
    indexNegative = find(posneg(idx).labels == -1);
    examplesNeg(neg+1:neg+length(indexNegative)) = posneg(idx).scores(indexNegative);
    neg = neg + length(indexNegative);
    
end

examplesPos(pos+1:end) = [];
examplesNeg(neg+1:end) = [];

pobj = pos/(pos+neg);

posLikelihood = hist(examplesPos,params.MS.bincenters)/length(examplesPos) + eps;
negLikelihood = hist(examplesNeg,params.MS.bincenters)/length(examplesNeg) + eps;

likelihood = [posLikelihood;negLikelihood];
end
