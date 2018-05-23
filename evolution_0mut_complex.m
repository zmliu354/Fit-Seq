function [ file_name ] = evolution_0mut_complex(lineage, t_evo, ...
    cell_num_ini, x_ini, deltat, read_depth_average, noise_option, ...
    varargin)
% -------------------------------------------------------------------------
% evolution_0mut_completed
% COMPLEX VERSION OF SIMULATED COMPETETIVE POOLED GROWTH OF A POPULATION OF 
% GENOTYPES WITH DIFFERENT FITNESSES [DEFINE WHAT MAKES THIS COMPLEX]
%
% INPUTS
% -- lineage: number of genotypes of the population
% -- t_evo: total number of growth generations
% -- cell_num_ini: vector of initial cell number of each genotype at the 0-th
%                  generation
% -- x_ini: vector of the fitness of each genotype
% -- deltat: number of generations between successive cell transfers
% -- read_depth_average: average read number of reads per genotype per sequencing
%                        time point
% -- noise_option: options of whether five types of noise (cell growth,
%                  bottleneck transfer, DNA extraction, PCR, sequencing)
%                  are simulated, 1*5 logical (0-1) vector [EXPLAIN WHAT HAPPENS IN THE CASE OF A 0 OR 1]
% -- 'format': optional, file format of the output file, 'csv'(default) or 'mat'
%
% OUTPUTS
% -- file_name: name of the file generated [WHAT IS OUTPUT TO THIS FILE?]
% -------------------------------------------------------------------------

% Parse inputs
numvarargs = length(varargin);
if numvarargs > 2
    error('evolution_0mut_complex:TooManyInputs', ...
        'requires at most 1 optional inputs');
end
optargs = {'format', 'csv'};
optargs(1:numvarargs) = varargin;
ouptput_format = optargs{2};


noise_growth = noise_option(1);
noise_bottleneck_transfer = noise_option(2);
noise_genome_DNA_extraction = noise_option(3);
noise_barcode_PCR = noise_option(4);
noise_sequencing = noise_option(5);

cell_num_evo = zeros(lineage, t_evo+1);
cell_num_evo(:,1) = cell_num_ini;
cell_num_evo_flask = cell_num_evo; % cell number in flask after transferred
x_mean = nan(1,t_evo+1);
x_mean(1) = cell_num_ini'*x_ini/sum(cell_num_ini);

t_seq_vec = 0:deltat:t_evo;


% Simulate Pooled growth [CAN YOU GIVE A FEW MORE DESCRIPTIONS THROUGHOUT?]
cell_min = zeros(lineage, t_evo+1);
cell_min(:,1) = cell_num_ini;
if noise_bottleneck_transfer == 0
    for j1 = 2:(t_evo+1)
        cell_min(:,j1) = round(cell_num_ini/(2^(floor((j1-2)/deltat)*deltat)));
    end
elseif noise_bottleneck_transfer == 1
    for j1 = 2:(t_evo+1)
        cell_min(:,j1) = poissrnd(cell_num_ini/(2^(floor((j1-2)/deltat)*deltat)));
    end
end

tstart0 = tic;
if noise_growth==0 && noise_bottleneck_transfer==0
    if deltat>=2
        for j = 2:deltat
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo(:,j-1)~=0;
            n_prev = cell_num_evo(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
        for j = (deltat+1):(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            if mod(j-1,deltat) == 0
                pos = cell_num_evo(:,j-1)~=0;
                n_prev = cell_num_evo(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = round(cell_num_evo(:,j)/2^deltat);
            elseif mod(j-1,deltat) ~= 0
                pos = cell_num_evo_flask(:,j-1)~=0;
                n_prev = cell_num_evo_flask(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            end
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    elseif deltat == 1
        for j = 2:(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo_flask(:,j-1)~=0;
            n_prev = cell_num_evo_flask(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = round(cell_num_evo(:,j)/2);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    end

    
elseif noise_growth==1 && noise_bottleneck_transfer==0
    if deltat>=2
        for j = 2:deltat
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo(:,j-1)~=0;
            n_prev = cell_num_evo(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
        for j = (deltat+1):(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            if mod(j-1,deltat) == 0
                pos = cell_num_evo(:,j-1)~=0;
                n_prev = cell_num_evo(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = round(cell_num_evo(:,j)/2^deltat);
            elseif mod(j-1,deltat) ~= 0
                pos = cell_num_evo_flask(:,j-1)~=0;
                n_prev = cell_num_evo_flask(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            end
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    elseif deltat == 1
        for j = 2:(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo_flask(:,j-1)~=0;
            n_prev = cell_num_evo_flask(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = round(cell_num_evo(:,j)/2);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    end
    
    
elseif noise_growth==0 && noise_bottleneck_transfer==1
    if deltat >=2
        for j = 2:deltat
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo(:,j-1)~=0;
            n_prev = cell_num_evo(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
        for j = (deltat+1):(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            if mod(j-1,deltat) == 0
                pos = cell_num_evo(:,j-1)~=0;
                n_prev = cell_num_evo(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = poissrnd(cell_num_evo(:,j)/2^deltat);
            elseif mod(j-1,deltat) ~= 0
                pos = cell_num_evo_flask(:,j-1)~=0;
                n_prev = cell_num_evo_flask(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            end
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    elseif deltat == 1
        for j = 2:(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo_flask(:,j-1)~=0;
            n_prev = cell_num_evo_flask(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(round(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = poissrnd(cell_num_evo(:,j)/2);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    end
    
    
elseif noise_growth==1 && noise_bottleneck_transfer==1
    if deltat >=2
        for j = 2:deltat
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo(:,j-1)~=0;
            n_prev = cell_num_evo(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
        for j = (deltat+1):(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            if mod(j-1,deltat) == 0
                pos = cell_num_evo(:,j-1)~=0;
                n_prev = cell_num_evo(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = poissrnd(cell_num_evo(:,j)/2^deltat);
            elseif mod(j-1,deltat) ~= 0
                pos = cell_num_evo_flask(:,j-1)~=0;
                n_prev = cell_num_evo_flask(pos,j-1);
                x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
                cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
                cell_num_evo_flask(:,j) = cell_num_evo(:,j);
            end
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    elseif deltat == 1
        for j = 2:(t_evo+1)
            if mod(j,20) == 1
                fprintf('Current generation: %i\n', j-1)
            end
            pos = cell_num_evo_flask(:,j-1)~=0;
            n_prev = cell_num_evo_flask(pos,j-1);
            x_ini_rela = max((1+x_ini(pos))/(1+x_mean(j-1)),0);
            cell_num_evo(pos,j) = max(poissrnd(2*n_prev.*x_ini_rela),cell_min(pos,j));
            cell_num_evo_flask(:,j) = poissrnd(cell_num_evo(:,j)/2);
            x_mean(j) = cell_num_evo(:,j)'*x_ini/sum(cell_num_evo(:,j));
        end
    end
end

% effective_cell_depth = sum(cell_num_evo_flask(:,t_seq_vec+1))*deltat;
effective_cell_depth = sum(cell_num_evo_flask(:,t_seq_vec+1));

telaps0=toc(tstart0);
fprintf('Computing time for %i generations: %f seconds.\n', t_evo, telaps0)


% After pooled growth
cell_num_mat_data = cell_num_evo(:,t_seq_vec+1);
copy_number_PCRtemplate = 500;
% copy_number_PCRtemplate: copy number per genotype for PCR template, >=500

genomeDNA_percentage = copy_number_PCRtemplate/...
    (mean(cell_num_ini)*2^deltat);
% cell_num_mat_data*(1-1/2^deltat)*(copy_number_PCRtemplate*lineage)/...
% (mean(cell_num_ini)*lineage*(2^dletat-1))...
% = cell_num_mat_data*copy_number_PCRtemplate/(mean(cell_num_ini)*2^dletat)

PCR_cycle_number = 25; % PCR_cycle_number: number of cycles in PCR
PCR_percentage = 0.01; % PCR_percentage: percantage of total PCR product
%                        sent for sequencing

if noise_genome_DNA_extraction==0 && noise_barcode_PCR==0 && ...
        noise_sequencing==0
    num_mat_DNA = floor(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = floor(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = floor(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = floor(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = floor(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
    
elseif noise_genome_DNA_extraction==1 && noise_barcode_PCR==0 && ...
        noise_sequencing==0
    num_mat_DNA = poissrnd(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = poissrnd(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = floor(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = floor(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = floor(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
    
elseif noise_genome_DNA_extraction==0 && noise_barcode_PCR==1 && ...
        noise_sequencing==0
    num_mat_DNA = floor(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = floor(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = poissrnd(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = poissrnd(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = floor(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
    
elseif noise_genome_DNA_extraction==0 && noise_barcode_PCR==0 && ...
        noise_sequencing==1
    num_mat_DNA = floor(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = floor(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = floor(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = floor(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = poissrnd(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
    
elseif noise_genome_DNA_extraction==1 && noise_barcode_PCR==1 && ...
        noise_sequencing==0
    num_mat_DNA = poissrnd(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = poissrnd(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = poissrnd(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = poissrnd(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = floor(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
    
elseif noise_genome_DNA_extraction==1 && noise_barcode_PCR==0 && ...
        noise_sequencing==1
    num_mat_DNA = poissrnd(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = poissrnd(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = floor(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = floor(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = poissrnd(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
    
elseif noise_genome_DNA_extraction==0 && noise_barcode_PCR==1 && ...
        noise_sequencing==1
    num_mat_DNA = floor(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = floor(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = poissrnd(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = poissrnd(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = poissrnd(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
    
elseif noise_genome_DNA_extraction==1 && noise_barcode_PCR==1 && ...
        noise_sequencing==1
    num_mat_DNA = poissrnd(cell_num_mat_data.*genomeDNA_percentage);
    num_mat_DNA(:,1) = poissrnd(cell_num_mat_data(:,1)*2^deltat.*...
        genomeDNA_percentage);
    num_mat_PCR_tempt = num_mat_DNA;
    for i1 = 1:PCR_cycle_number
        num_mat_PCR_tempt = poissrnd(2*num_mat_PCR_tempt);
    end
    num_mat_PCR = poissrnd(num_mat_PCR_tempt.*PCR_percentage);
    num_mat_sequencing = poissrnd(num_mat_PCR*read_depth_average*lineage./...
        sum(num_mat_PCR));
end


dt = datestr(now,'yyyymmdd-HHMMSSFFF');
switch lower(ouptput_format)
    case {'mat'}
        file_name = ['data_evo_simu_0mut_complex_' dt '.mat'];
        save(file_name, 'num_mat_sequencing','t_seq_vec',...
            'effective_cell_depth','cell_num_evo','x_mean',...
            'x_ini','cell_num_ini','lineage','t_evo','deltat',...
            'read_depth_average','noise_option')
        
    case {'csv'}
        file_name_1 = ['data_evo_simu_0mut_complex_' dt '_Reads.csv'];
        file_name_2 = ['data_evo_simu_0mut_complex_' dt '_SeuqencedTimepoints.csv'];
        file_name_3 = ['data_evo_simu_0mut_complex_' dt '_EffectiveCellDepth.csv'];
        file_name_4 = ['data_evo_simu_0mut_complex_' dt '_CellNumber.csv'];
        file_name_5 = ['data_evo_simu_0mut_complex_' dt '_MeanFitness.csv'];
        file_name_6 = ['data_evo_simu_0mut_complex_' dt '_Paramaters.csv'];
        csvwrite(file_name_1,num_mat_sequencing)
        csvwrite(file_name_2,t_seq_vec)
        csvwrite(file_name_3,effective_cell_depth)
        csvwrite(file_name_4,cell_num_evo)
        csvwrite(file_name_5,x_mean)
        output_parameters = cell(lineage+1,7);
        output_parameters{1,1} = 'Fitness of each genotype (x_i)';
        output_parameters{1,2} = ...
            'Initial cell number of each genotype (n0_i)';
        output_parameters{1,3} = 'Number of genotypes (L)';
        output_parameters{1,4} = 'Total number of generations grown (T)';
        output_parameters{1,5} = ...
            'Number of generations between successive cell transfers (Delta t)';
        output_parameters{1,6} = ...
            'Average read number per genotype per time point (R/L)';
        output_parameters{1,7} = 'Optional noise (noise_option)';
        output_parameters(2:end,1) = num2cell(x_ini);
        output_parameters(2:end,2) = num2cell(cell_num_ini);
        output_parameters{2,3} = lineage;
        output_parameters{2,4} = t_evo;
        output_parameters{2,5} = deltat;
        output_parameters{2,6} = read_depth_average;
        output_parameters{2,7} = ['[' num2str(noise_option) ']'];
        fileID = fopen(file_name_6,'wt');
        for k1 = 1:6
            fprintf(fileID,'%s,', output_parameters{1,k1});
        end
        fprintf(fileID,'%s\n', output_parameters{1,7});
        for k2 = 1:6
            fprintf(fileID,'%f,', output_parameters{2,k2});
        end
        fprintf(fileID,'%s\n', output_parameters{2,7});
        for k3 = 2:lineage
            fprintf(fileID,'%f,', output_parameters{k3+1,1});
            fprintf(fileID,'%f\n', output_parameters{k3+1,2});
        end
        fclose(fileID);
        file_name = ['data_evo_simu_0mut_complex_' dt];
end
return