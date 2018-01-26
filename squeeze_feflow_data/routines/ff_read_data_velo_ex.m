function [simtime,mat_data] = ff_read_data_velo_ex(file_id_v,num_nodes)


temp_data = (fscanf(file_id_v,'%f',[12,num_nodes]))';
        
mat_data(:,1:4) = temp_data(1:num_nodes,8:11);
simtime = unique(temp_data(:,2))*86400;

end