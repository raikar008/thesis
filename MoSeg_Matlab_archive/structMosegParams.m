% structMosegParams.m
%
% created on April 30, 2013
% written by Richard Lange
%
% this file defines the architecture of the 'mosegParams' struct. This
% struct defines all parameters of the algorithm
%
% parameters struct:
%   mosegParams.video_file = string. path to the video being processed
%   mosegParams.startframe = number.
%   mosegParams.endframe = number.
%   mosegParams.sampling = number. The sampling factor at initialization
%   mosegParams.init_threshold = number > 0. Portion of structure tensor's
%       second eigenvector considered textured-enough for initialization.
%       See Sundaram 2010. 
%   mosegParams.init_window = width of square window around each pixel to
%       look at for structure. Must be odd.

function mosegParams = structMosegParams

mosegParams.video_file = '../data/Youtube/10class/penguin/03.avi';
mosegParams.startframe = 1;
mosegParams.endframe = 30;
mosegParams.sampling = 8;
mosegParams.init_threshold = 1;
mosegParams.init_window = 9;
mosegParams.flow_variation_window = 7;
mosegParams.lambda = 0.1;
mosegParams.cluster_threshold = 0.2;

verifyMosegParams(mosegParams, 'structMosegParams.m');

end

