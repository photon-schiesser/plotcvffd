function plotCVFFD8(filepath,scale)

% filepath = 'C:\Users\Eric\Google Drive\MTW-OPAL\';
% filepath = 'C:\Users\Eric\Google Drive\WFOV\K30\Visible\';
% filepath = 'C:\Users\Eric\Google Drive\WFOV\ES250\AS2S1_pos_t1_0.61489_c2_1.8039\';
% filepath = 'C:\Users\eschi\Google Drive\MTW-OPAL\';
% filepath = 'C:\Users\eschi\Google Drive\MTW-OPAL\Doublet_tolerancing\';

% These filenames are static, and are determined by the exported filename
% from the Code V sequence file "ffdplot"
fnamebase = 'cv_ffd_';
nfiles = 8;
filenames = cell([nfiles 1]);

for j = 1:nfiles;
    filenames(j) = {fullfile(filepath, [fnamebase, int2str(j), '.dat'])};
end

scale_arg = 2;
if nargin < scale_arg;
    scale = [];
end

num_plots = nfiles;

[x, ~, ~, ~, ~] = readCVFFD(filenames{1});

npos = size(x,2);
hfig = gobjects(npos,1);
screensize = get(0,'ScreenSize');
aspect = 955/556;
width = 960;
height = width/aspect;

for j = 1:npos
    fig = figure('Position',[50 100 width height]);
    hfig(j) = fig;
end

for k = 1:num_plots
    for j = 1:npos
        figure(hfig(j))
        hax(j) = subplot(2,4,k);
    end
    plotCVFFD(filenames{k},scale,hax)
end