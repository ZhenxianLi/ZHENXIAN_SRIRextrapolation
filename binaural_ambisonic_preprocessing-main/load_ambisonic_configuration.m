%{
This test script illustrates how to generate binaural Ambisonic decoders
for Ambisonic orders 1 - 5. The HRTFs are included in \hrirs folder for the 
L = 50 Lebedev grid (from the excellent Bernschutz (2013) database), which 
have been diffuse-field equalised to a uniform RMS response between 20Hz - 
20kHz. The binaural Ambisonic decoder can be specified as either basic 
weighted or dual-band (basic at low frequencies and Max rE at high 
frequencies).

The user can then pre-process the HRIRs / SH binaural Ambisonic decoder.
The four possible pre-processing techniques are:
- Ambisonic Time Alignment
        Zaunschirm et al. (2018), Evans et al. (1998), and Richter (2014).
- Ambisonic ILD Optimisation
        "Interaural level difference optimisation of binaural Ambisonic rendering,"
        Applied Sciences, vol. 9, no. 6, 2019, T. McKenzie, D. T. Murphy, and G.
        Kearney.
- Ambisonic Diffuse-Field Equalisation
        "Diffuse-field equalisation of binaural Ambisonic rendering," Applied Sci-
        ences, vol. 8, no. 10, 2018, T. McKenzie, D. T. Murphy, and G. Kearney.
- Ambisonic Directional-Bias Equalisation
        "Directional bias equalisation of first order binaural Ambisonic rendering,"
        in AES Conference on Audio for Virtual and Augmented Reality, Redmond,
        USA, 2018, T. McKenzie, D. T. Murphy, and G. Kearney.
        "Towards a perceptually optimal bias factor for directional bias equalisa-
        tion of binaural Ambisonic rendering," in EAA Spatial Audio Signal Processing
        Symposium, (pp. 97{102), Paris, France, 2019, T. McKenzie, D. T. Murphy, and G.
        Kearney.

Finally, the user can export the HRIRs as .wav files for use in other
applications, VST plugins, etc.

Thomas McKenzie, University of York, 2019. Any queries please email
thomas.mckenzie@ed.ac.uk
        "High frequency reproduction in binaural Ambisonic rendering." PhD Thesis, 
        University of York, 2019, T. McKenzie.

%}

%%
clear variables; close all; clc;
%addpath('D:\OneDrive - University of Edinburgh\2223_3_FinalProjrct\FP_matlab\binaural_ambisonic_preprocessing-main')
addpath(genpath('./ambisonics/'));
addpath(genpath('./hrirs/'));
addpath(genpath('./pre_processing_techniques'));
addpath(genpath('./signal_processing'));
addpath(genpath('./test_scripts'));
addpath(genpath('./voronoi_solid_angle'));

ambisonic_order = 4; % specify Ambisonic order here
dualband_flag   = 1; % specify decoder type (basic = 0, dual-band = 1)
export_HRIRs    = 0; % specify whether to export pre-processed HRIRs

% Choose pre-processing techniques
ta_flag  = 1;
aio_flag = 1;
dfe_flag = 1;
dbe_flag = 0; bias_factor = 33; bias_direction = [0 0]; % bias_direction should be in degrees in [azimuth elevation]

% Load virtual loudspeaker HRIRs
[loudspeaker_directions, VL_hrirs_NPP,Fs] = load_hrirs_lebedev(ambisonic_order);
VL_hrirs = VL_hrirs_NPP;

% Encode HRIRs into a binaural Ambisonic decoder - NPP (no pre-processing)
SH_ambisonic_binaural_decoder_NPP = generate_binaural_Ambisonic_decoder(ambisonic_order, VL_hrirs_NPP,loudspeaker_directions,dualband_flag);

%% Pre-process HRIRs

if ta_flag == 1 % Ambisonic Time-Alignment
    [VL_hrirs] = ambisonic_time_alignment(VL_hrirs,Fs,ambisonic_order);
end

% Encode HRIRs into a binaural Ambisonic decoder
SH_ambisonic_binaural_decoder = generate_binaural_Ambisonic_decoder(ambisonic_order, VL_hrirs,loudspeaker_directions,dualband_flag);

if aio_flag == 1 % Ambisonic ILD Optimisation
    [SH_ambisonic_binaural_decoder,VL_hrirs] =  ambisonic_ILD_optimisation(ambisonic_order,SH_ambisonic_binaural_decoder,VL_hrirs,VL_hrirs_NPP,Fs,loudspeaker_directions,dualband_flag);
end

dfe_plot_flag = 1;
if dfe_flag == 1 % Ambisonic Diffuse-Field Equalisation
    [SH_ambisonic_binaural_decoder,VL_hrirs] = ambisonic_diffuse_field_equalisation(ambisonic_order,SH_ambisonic_binaural_decoder,VL_hrirs,Fs,dfe_plot_flag);
end

dbe_plot_flag = 1;
if dbe_flag == 1 % Ambisonic Directional Bias Equalisation
    [SH_ambisonic_binaural_decoder,VL_hrirs] = ambisonic_directional_bias_equalisation(ambisonic_order,SH_ambisonic_binaural_decoder,bias_factor,bias_direction,VL_hrirs,Fs,dbe_plot_flag);
end

%% Export final pre-processed HRIRs

if export_HRIRs == 1 % Export as .wav files
    export_directory = 'hrirs_pre_processed';
    mkdir(export_directory);
    for i = 1:length(VL_hrirs(1,1,:))
        audiowrite(strcat(export_directory,'/azi_',num2str(loudspeaker_directions(i,1)),'_ele_'...
            ,num2str(loudspeaker_directions(i,2)),'_PP.wav'),VL_hrirs(:,:,i)',Fs);
    end
    disp('Pre-processed HRIRs exported!');
end

%% Run test script
%test_ambisonic_decoder
