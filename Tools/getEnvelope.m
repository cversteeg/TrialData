%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function trial_data = getEnvelope(trial_data, params)
%
%   Computes the envelope of a signal. Rectifies and then low-pass filters
% the signal.
%
% Written by Matt Perich. Updated October 2018.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trial_data = getEnvelope(trial_data,params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
signals  = '';
decenter = true;
filt_order = 4;
lp_cutoff = 20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isstruct(params)
    signals = params;
else
    assignParams(who,params);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
signals = check_signals(trial_data,signals);

fs = round(1/trial_data(1).bin_size);

for iSig = 1:size(signals,1)
    if decenter
        m = mean(getSig(trial_data,signals{1,1}),1);
    else
        m = zeros(1,size(trial_data(1).(signals{1,1}),2));
    end
    
    for trial = 1:length(trial_data)
        sig = trial_data(trial).(signals{iSig,1});
        sig = sig(:,signals{iSig,2});
        
        % subtract mean
        sig  = sig - repmat(m,size(sig,1),1);
        % rectify, preserving energy in signal
        sig = 2 * sig.*sig;
        
        %% Low Pass
        [b,a] = butter(filt_order,lp_cutoff/fs,'low');
        for i = 1:size(sig,2)
            sig(:,i) = filtfilt(b, a, sig(:,i));
        end
        
        % take square root since we squared it above
        sig = abs(sqrt(sig));
        
        trial_data(trial).(signals{iSig,1}) = sig;
    end
end

