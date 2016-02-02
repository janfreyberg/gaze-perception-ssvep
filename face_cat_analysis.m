% clearvars;
 %#ok<*SAGROW>

 electrodes = [20:31, 57:62, 64];
 
%% Trial definition
cfg_deftrials.dataset = 'E:\Documents\Recorded Data\Piloting Data\faces1.bdf';
cfg_deftrials.trialdef.eventtype = 'STATUS';
cfg_deftrials.trialfun = 'ft_trialfun_general';
cfg_deftrials.trialdef.prestim = 0; % discard first 500ms
cfg_deftrials.trialdef.poststim = 20; %actual length of trial 8 s
cfg_deftrials.trialdef.eventvalue = 1:12; % Trials are numbered 1-12

cfg_deftrials = ft_definetrial(cfg_deftrials);
    

%% Preprocessing

cfg_preproc = cfg_deftrials;
cfg_preproc.dataset = 'E:\Documents\Recorded Data\Piloting Data\faces1.bdf';
cfg_preproc.continuous = 'yes';
cfg_preproc.demean    = 'yes';
cfg_preproc.detrend = 'yes';
% Bandpass Filter
cfg_preproc.bpfilter = 'yes';
cfg_preproc.bpfreq = [0.1 100];
%     cfg_preproc.reref = 'yes';
%     cfg_preproc.refchannel = 1:64;
%     cfg_preproc.channel = 1:64;
cfg_preproc.channel = 1:64;
cfg_preproc.trl = cfg_deftrials.trl;
prep_data = ft_preprocessing(cfg_preproc);

%% FFT
cfg_fft = [];
cfg_fft.continuous = 'yes';
cfg_fft.output = 'pow';
cfg_fft.method = 'mtmfft';
cfg_fft.foilim = [0.5 16];
cfg_fft.tapsmofrq = 0.25;
cfg_fft.channel = electrodes;
cfg_fft.keeptrials = 'no';

freqs = ft_freqanalysis(cfg_fft, prep_data);

%% Single Plot of Spectrum
figure;
plot(freqs.freq, freqs.powspctrm);

cfg_plot = [];
cfg_plot.parameter = 'powspctrm';
ft_singleplotTFR(cfg_plot, freqs);




%% Cross-trial variation
% for trialTypes = 1:2
%     
%     signal = freqs{trialTypes}.freq<=data{trialTypes}.stimfreq + 0.14 & freqs{trialTypes}.freq>=data{trialTypes}.stimfreq - 0.14;
%     noise = ~signal & (freqs{trialTypes}.freq<=data{trialTypes}.stimfreq + 4 & freqs{trialTypes}.freq>=data{trialTypes}.stimfreq - 4);
%     
%     cross_sd{trialTypes} = nanstd( nanmean( max( freqs{trialTypes}.powspctrm(:, :, signal), [], 3 ), 2), [], 1) ;
%     
%     
%     cross_sd_average{group}(participant_num, trialTypes) = mean(cross_sd{trialTypes});
% end


%% Trial Selection?
% clear trialselection;
% if ~exist(fullfile( pwd, 'Preprocessing', [file_list{group}(participant_num).name(1:end-4), '-trialselec', '.mat']), 'file');
% for trialTypes = 1:2
% for trialNum = 1:size(data{trialTypes}.data.time, 2)
%     
%     temp_data = strip_trials(data{trialTypes}.data, trialNum);
%     
%     temp_freqs = ft_freqanalysis(cfg_fft, temp_data);
%     
%     hold off;
%     p1 = plot(temp_freqs.freq, temp_freqs.powspctrm(1, :), 'r');
%     hold on;
%     p2 = plot(temp_freqs.freq, temp_freqs.powspctrm(2, :), 'b');
%     ylim([0 0.5]);
%     legend(temp_freqs.label);
%     drawnow;
%     
%     trialselection{trialTypes}(trialNum) = input('Trial OK? 1/0\n');
% end
% end
%     save(fullfile( pwd, 'Preprocessing', [file_list{group}(participant_num).name(1:end-4), '-trialselec', '.mat']), 'trialselection');
% else
%     load(fullfile( pwd, 'Preprocessing', [file_list{group}(participant_num).name(1:end-4), '-trialselec', '.mat']), 'trialselection');
% end

%% Compute the SSVEP statistics

for trialTypes = 1:2
    
    signal = freqs{trialTypes}.freq<=data{trialTypes}.stimfreq + 0.14 & freqs{trialTypes}.freq>=data{trialTypes}.stimfreq - 0.14;
    noise = ~signal & (freqs{trialTypes}.freq<=36 + 4 & freqs{trialTypes}.freq>=28.8 - 4);
    
    snr{trialTypes} = max(freqs{trialTypes}.powspctrm(:, signal), [], 2) ./ mean(freqs{trialTypes}.powspctrm(:, noise), 2);
    
    snr_electrodes{group}(participant_num, trialTypes, :) = snr{trialTypes};
    
    snr_average{group}(participant_num, trialTypes) = mean(snr{trialTypes});
end

%% Compute the size of the SSVEP

for trialTypes = 1:2;
    
    signal = freqs{trialTypes}.freq<=data{trialTypes}.stimfreq + 0.14 & freqs{trialTypes}.freq>=data{trialTypes}.stimfreq - 0.14;
    
    amps = max(freqs{trialTypes}.powspctrm(:, signal), [], 2);
    
    amp_average{group}(participant_num, trialTypes) = mean(amps);
    
end

%% Plot the average spectrum for each group
for trialTypes = 1:2;
    
    signal = freqs{trialTypes}.freq<=data{trialTypes}.stimfreq + 0.14 & freqs{trialTypes}.freq>=data{trialTypes}.stimfreq - 0.14;
    
    amps = mean(freqs{trialTypes}.powspctrm(:, :), 1);
    
    spec_average{group}(participant_num, trialTypes, :) = amps;
    
end


%% Compute the spatial spread of the spectrum
for trialTypes = 1:2
    
    signal = freqs{trialTypes}.freq<=data{trialTypes}.stimfreq + 0.14 & freqs{trialTypes}.freq>=data{trialTypes}.stimfreq - 0.14;
    
    
%     norm_freq{group, trialTypes, participant_num} = group_freqs{group, trialTypes, participant_num};
    
%     norm_freq{group, trialTypes, participant_num}.powspctrm = norm_freq{group, trialTypes, participant_num}.powspctrm./...
%                                                                 max( max(norm_freq{group, trialTypes, participant_num}.powspctrm(:, signal), [], 2), [], 1);
    
    
    
    
end



% Compare amplitudes at diff electrodes


















