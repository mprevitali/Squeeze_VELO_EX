function [num_nodes,V_nodes] = ff_read_mesh_velo_ex(filename)
file_id = fopen(filename);
fgetl(file_id);
line_data = fscanf(file_id,'%f',[12 1])';
num_nodes = 1;
while feof(file_id)==0 && line_data(1)==1
mesh_data(num_nodes,:)=line_data;
num_nodes = num_nodes +1;
line_data = fscanf(file_id,'%f',[12 1])';
end
fclose(file_id);
V_nodes = mesh_data(:,5:7);
end