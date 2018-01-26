clear all
addpath('routines');
cd('input');
Files=[dir('*.dat')];
pattern = 'velocities';
for i = 1:size(Files)
    Files2{i} = Files(i).name;
end
folder = Files(1).folder;
Files = Files2;
Files(contains(Files,pattern,'IgnoreCase',true))=[];


for File_idx = 1:length(Files)
    filename = Files{File_idx};
    [num_fault_nodes,fault_mesh_data] = ff_read_mesh_velo_ex([folder,'/',sprintf('velocities_%s',filename)]);
    [mesh_data] = ff_read_mesh_Feflow([folder,'/',filename]);
    
    file_id = fopen(filename,'r');
    file_id_v = fopen(sprintf('velocities_%s',filename),'r');
    fgetl(file_id);
    fgetl(file_id_v);
    
    intersection_index = ismember(floor(mesh_data),floor(fault_mesh_data),'rows');
    intersection_index_fault = ismember(floor(fault_mesh_data),floor(mesh_data),'rows');
    num_nodes_temp = size(mesh_data,1);
    num_nodes_vel = size(fault_mesh_data,1);
    mat_data = nan(sum(intersection_index),9);
    fid = fopen(sprintf('squeezed_%s',filename),'w');
    fprintf(fid,'%i\n',sum(intersection_index));
    while feof(file_id)== 0 &&  feof(file_id_v)==0
        %   calcola i nodi comuni tra tutta la mesh e la faglia
        
        %   lettura delle temperature
        [sim_time,T_data] = ff_read_data_Feflow(file_id,num_nodes_temp);
        disp(['Importing temperature matrix at simulation time: ',num2str(sim_time),' seconds.']);
        
        %   letture delle velocità
        if sim_time > 0
            [sim_time_vel,V_data] = ff_read_data_velo_ex(file_id_v,num_nodes_vel);
            while (sim_time > 0 && abs(sim_time - sim_time_vel) >= 1e9 && feof(file_id_v)==0  ) %
                [sim_time_vel,V_data] = ff_read_data_velo_ex(file_id_v,num_nodes_vel);
                disp(['Importing velocity matrix at simulation time: ',num2str(sim_time_vel),' seconds.']);
                if sim_time_vel > sim_time  + sim_time/10
                    error('error sim velo troppo alto');
                    
                elseif (sim_time-sim_time_vel)> 1e11
                    error('error sim velo troppo basso');
                    
                end
            end
            %   costruzione della matrice dei valori nodali standard
            mat_data(:,1) = repmat(sim_time_vel,sum(intersection_index),1);
            mat_data(:,2:4) = mesh_data(intersection_index,:);
            mat_data(:,5) = T_data(intersection_index);
            mat_data(:,6:9) = V_data(intersection_index_fault,:);
            
            disp('Writing..');
            for i = 1:size(mat_data,1)
                %disp(['Wrote line: ',num2str(i)]);
                fprintf(fid,'%.20f %.20f %.20f %.20f %.20f %.20f %.20f %.20f %.20f \n',mat_data(i,:));
            end
        end
    end
    fclose('all');
    movefile(sprintf('squeezed_%s',filename),strrep(sprintf('../output/squeezed_%s',filename),'.dat','.asc'));
    disp(['Generated ',strrep(sprintf('squeezed_%s',filename),'.dat','.asc')]);
    delete(filename);
    delete(sprintf('velocities_%s',filename));
end
   