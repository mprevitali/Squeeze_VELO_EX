function [sim_time,T_data] = ff_read_data_Feflow(file_id,num_nodes)
        temp_data = (fscanf(file_id,'%f',[8,num_nodes]))';  
        if ~isempty(temp_data)
        T_data = temp_data(1:num_nodes,7);     
        sim_time = unique(temp_data(1:num_nodes,8));
        else
            T_data = -1;
            sim_time = -1;
        end

end

